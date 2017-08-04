# name: wiki-bot
# about: Replies new topic with default wiki post
# version: 0.1
# authors: Bolarinwa Balogun end Evg
# url: https://github.com/Toxu-ru/wiki-bot

enabled_site_setting :response_enabled

after_initialize do

    class ::Category
        after_save :reset_response_cache

        protected
        def reset_response_cache
            ::Guardian.reset_response_cache
        end
    end

    class ::Guardian
        @@allowed_response_cache = DistributedCache.new("allowed_response")

        def self.reset_response_cache
            @@allowed_response_cache["allowed"] =
            begin
                Set.new(
                CategoryCustomField
                    .where(name: "enable_response_bot", value: "true")
                    .pluck(:category_id)
                )
            end
        end

        def self.allow_response_bot_on_category?(category_id)
            return true if SiteSetting.allow_solved_on_all_topics

            unless set = @@allowed_response_cache["allowed"]
                set = reset_response_cache
            end
            set.include?(category_id)
        end

        def self.can_respond_topic?(topic)
            self.allow_response_bot_on_category?(topic.category_id) && 
            (!topic.closed?) & SiteSetting.response_enabled
    
        end
    end

    # Check if user already exists
    # using a negative number to ensure it is unique
    user = User.find_by(id: -10)

    # user created
    if !user
        response_username = "wiki_bot"
        response_name = "Wiki bot"
        
        user = User.new
        user.id = -10
        user.name = response_name
        user.username = response_username
        user.email = "student_response@me.com"
        user.username_lower = response_username.downcase
        user.password = SecureRandom.hex
        user.active = true
        user.approved = true
        user.trust_level = TrustLevel[1]
    end

    # event listener for creation of new topic
    # once a topic is created, automatically reply topic with wiki post
    DiscourseEvent.on(:topic_created) do |topic|
        if ::Guardian.can_respond_topic?(topic)
            post = PostCreator.create(user,
                        topic_id: topic.id,
                        raw: I18n.t('bot.default_message'))
            post.wiki = true
            post.save(validate: false)
        end
    end
end
