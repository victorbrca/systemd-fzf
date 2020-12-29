# systemd-fzf
A systemctl alias that uses fzf

**Demo Video** - https://streamable.com/e/r64azs

Installation
---

Add or source the contents of [systemd.bash](systemd.bash) to your `~/.bash_aliases`. 

Usage
---

You can use `sc` with most of the `systemctl` commands. Please note that some work better (like unit files control), while others are not yet supported. 

+ **unit files options not yet supported**
  - link
  - revert
  - add-wants
  - add-requires
+ **Non unit files commads**
  - Currently support up to 1 argumet


### Help

You can get help with the `-h` option:

```
➤ sc -h
Usage: sc [cmd {user}|service [unit] [system|user] [unit command] {now}]
examples:
	sc service cupsd.service system restart
	sc service mpd.service user restart
	sc service mpd.service enable now user
	sc daemon-reload
	sc daemon-reload user
```

### Command structure

#### Unit files (`service`)

Start a system service

    sc service [unit].service system start

Start a user service

    sc service [unit].service user start

Enable a service

    sc service [unit].service [system|user] enable {now}

#### Non unit files commands

Daemon reload

    sc daemon-reload
