# backroom
<img src="https://github.com/TeaHouseLab/TeaHouseArtworks/blob/main/OtherProjects/backroom.svg?raw=true" alt="logo" style="width:256px;"/>

A new virtualization system built on chroot, nspawn and QEMU+kvm with api support built-in

**BackRoom - TeaHouseLab's next level high performance virtualization system**

# Levels
Levels are isolated space in backroom(For older: it's virtual machines)

Levels can be entered (load/boot or whatever) with QEMU+kvm(full virtualization) or nspawn(os level virtualization)

# Service
Levels can be bring up from their service

# help doc
```
Build_Time_UTC=2022-08-30_07:55:48

(./)app [root] [logcat] [enter, manage, host, v/version, h/help]
    root: The root of your backroom storage, all levels will be store here
    
    logcat: Log output level
        Available: [info/*, debug]
    
    enter: Enter a backroom level (Aka. boot a virtual machine)
        Subcommand: [nspawn, chroot]

            enter chroot: Enter the level with chroot
            (!)This should be only used when configuring a level
            (?)Enter Level with Full control to host, only with file system level containment
            Synatax: enter chroot [target] [exec]
            [target]: uuid/alias of the level
            [exec]: command to be executed

            enter nspawn: Boot the level with nspawn
                Subcommand: [exec, boot]

                    exec: Only try to enter a level and execute commands
                    Synatax: enter nspawn exec [target] [exec]
                    [target]: uuid/alias of the level
                    [exec]: command to be executed
                    Example: backroom ./test debug enter nspawn exec a0d9300af25b473e95198427b2213008 bash

                    boot: Search and boot the level`s init system
                    (!)Need systemd-networkd to setup NAT layer for level(machine)
                    Synatax: enter nspawn boot [target] [ports]
                    [target]: uuid/alias of the level
                    [ports]: ports to be exposed
                    Example: backroom ./test debug enter nspawn boot a0d9300af25b473e95198427b2213008
    
    manage: Manage backroom levels (Aka. setup/configure/manage a machine)
        Subcommand: [level, service]

        manage level: Manage levels
            Subcommand: [add, del, info, list, alias]
            
            level add: Create new levels from remote lxc repo
                Syntax: level add [remote - http(s) only] [targets]
                Example: backroom ./test debug manage level add https://mirrors.bfsu.edu.cn/lxc-images ubuntu:xenial:s390x:default ubuntu:xenial:amd64:default
                
            level del: Destroy levels
                Syntax: level del [targets]
                (!)Target has to be specific uuid of the level
                Example: backroom ./test debug manage level del f6c23a26881f4bf8bf9aa2af19d38548 a0d9300af25b473e95198427b2213008
                
            level info: Print the info of levels
                Syntax: level info [targets]
                Example: backroom ./test debug manage level info a0d9300af25b473e95198427b2213008

            level list: Print installed and available levels
                Subcommand: [available, installed]

                list available: List available levels in remote lxc repo
                Synatax: list available [remote - http(s) only]

                list installed: List installed levels in this root
                Synatax: list installed

            level alias: Set an alias for a level
                Syntax: level alias [target-uuid] [alias name]
                Example: backroom ./test debug manage level alias a0d9300af25b473e95198427b2213008 Earth
        
        manage service: Manage systemd services for levels
            Subcommand: [add, del, edit, power, stat]

            service add: Add services for levels
                Synatax: service add [targets]
                Example: backroom ./test debug manage service add Earth f6c23a26881f4bf8bf9aa2af19d38548

            service del: Remove services for levels
                Synatax: service del [targets]
                Example: backroom ./test debug manage service del Earth f6c23a26881f4bf8bf9aa2af19d38548

            service edit: Edit services for levels using nano
                Synatax: service edit [targets]
                Example: backroom ./test debug manage service edit Earth

            service power: Power on/off backroom levels through their services
                Synatax: service power [on/off/reboot] [targets]
                Example: backroom ./test debug manage service power on Earth f6c23a26881f4bf8bf9aa2af19d38548

            service stat: Print stats of levels in index
                Synatax: service stat Earth
                Example: backroom ./test debug manage service stat Earth
            
    host: Run backroom as an daemon, provide custom api for easier hosting in OpenVZ style
    
    v/version: Print version
    
    h/help: Show this msg again
```

