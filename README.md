# Discourse Wiki Bot
This is a <a href="https://www.discourse.org/">Discourse</a> plugin. It works as a bot automatically replying newly created topics within a Discourse forum with a default wiki post. This allows users to collaborate and construct a single answer for topics created.

## Installation

```yml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - mkdir -p plugins
          - git clone https://github.com/Toxu-ru/wiki-bot.git
```
rebuild your container:

```
cd /var/discourse
git pull
./launcher rebuild app
```

## License
MIT
