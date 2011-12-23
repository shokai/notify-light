notify light
============
check brightness in room, notify skype


Dependencies
------------

* [Serial HTTP Gateway](https://github.com/shokai/serial-http-gateway)
* [Skype Chat Gateway for Mac](https://github.com/shokai/skype-chat-gateway-mac) or for [Linux](https://github.com/shokai/skype-chat-gateway-linux)


Install Gems
------------

    % gem install json ArgsParser

Run
---

    % ruby notify-light.rb -help
    % ruby notify-light.rb -light http://localhost:8783/ -skype http://localhost:8787/