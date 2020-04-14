# updsched

Have you ever gotten tired of downloading updates on your own?

Have you ever wished for a systemd service that would download updates for you but wouldn't install it automatically so you'd be still in control of your updates?

Say no more!

# Dependencies
* pacman
* sudo
* libnotify
* dunst
* iputils

# Notes

updsched requires dunst notification daemon to be running in UID 1000's graphical session to work correctly.

# License
This software is licensed under GNU AGPLv3's terms. (see [LICENSE](https://github.com/head47/updsched/LICENSE.md) for more info)
