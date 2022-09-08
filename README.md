# backroom
<img src="https://github.com/TeaHouseLab/TeaHouseArtworks/blob/main/OtherProjects/backroom.svg?raw=true" alt="logo" style="width:256px;"/>

A new virtualization management system built on chroot, nspawn and QEMU+kvm with api support built-in

**BackRoom - TeaHouseLab's next level low performance virtualization system**

# Levels
Levels are isolated space in backroom(aka virtual machines)

Levels can be launched (load/boot or whatever) with QEMU+kvm or nspawn(os-level virtualization)

# Service
Levels can be brought up from their service

# help doc
```
(./)app [root] [logcat] [enter, manage, host, v/version, h/help]
    root: The root of your backroom storage, all levels will be store here
    
    logcat: Log output level
        Available: [info/*, debug]
    
    enter: Enter a backroom level (Aka. boot a virtual machine)
        Subcommand: [nspawn, chroot, kvm]

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
                    Synatax: enter nspawn boot [target] [ports] [core] [ram] [extra nspawn args]
                    [target]: uuid/alias of the level
                    [ports]: ports to be exposed(format: a-b or a,b or a)
                    Example: backroom ./test debug enter nspawn boot a0d9300af25b473e95198427b2213008 22-25 50% 1024

            enter kvm: Boot the level with qemu+kvm
                Synatax: enter kvm [target] [ports] [core] [ram] [extra qemu args]
                [target]: uuid/alias of the level
                [ports]: ports to be exposed
                Example: backroom ./test debug enter kvm a0d9300af25b473e95198427b2213008 '' 1 1024 -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd
    
    manage: Manage backroom levels (Aka. setup/configure/manage a machine)
        Subcommand: [level, service]

        manage level: Manage levels
            Subcommand: [add, del, info, tar,list, alias]
            
            level add: Create new levels from remote lxc repo or local disk image
                Subcommand: [rootfs, kvm]
                
                add rootfs: Create levels as rootfs from remote repo(nspawn, chroot)
                    Synatax: add rootfs [remote - http(s) only] [targets]
                    Example: backroom ./test debug manage level add rootfs https://mirrors.bfsu.edu.cn/lxc-images ubuntu:xenial:s390x:default ubuntu:xenial:amd64:default

                add kvm: Create a level as qcow2 disk image from local disk image(kvm+qemu)
                    Synatax: add kvm [target]
                    [target]: Will be the seed(template) of the new level
                    Example: backroom ./test debug manage level add kvm ../template/debian-11.qcow2
                
            level del: Destroy levels
                Syntax: level del [targets]
                (!)Target has to be specific uuid of the level
                Example: backroom ./test debug manage level del f6c23a26881f4bf8bf9aa2af19d38548 a0d9300af25b473e95198427b2213008
                
            level info: Print the info of levels
                Syntax: level info [targets]
                Example: backroom ./test debug manage level info a0d9300af25b473e95198427b2213008

            level tar: Tar or Untar levels (backup levels) into one compressed datapack
                Subcommand:: [tar, untar]

                tar tar: Tar (backup) levels
                Synatax: tar tar [targets]
                Example: backroom . debug manage level tar tar Earth Moon

                tar untar: Untar (import) levels
                Synatax: tar untar [datapack]
                Example: backroom . debug manage level tar untar the_world.brpack

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
                Subcommand: [rootfs, kvm]

                add rootfs: Add services for rootfs levels
                    Synatax: add rootfs [targets]
                    Example: backroom ./test debug manage service add rootfs Earth f6c23a26881f4bf8bf9aa2af19d38548

                add kvm: Add services for kvm levels
                    Synatax: add kvm [targets]
                    Example: backroom ./test debug manage service add kvm Earth f6c23a26881f4bf8bf9aa2af19d38548

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
        Subcommand: [s, ss]

            host s: Run api server without ssl encrypted (Not recommend)
            Synatax: host s [port] [address]
            Example: backroom . debug host s 8080 0.0.0.0

            host ss: Run api server with ssl encrypted
            Synatax: host ss [port] [address] [cert] [key]
            Example: backroom . debug host ss 443 0.0.0.0 /home/fullchain.crt /home/server.key

        [api documents]
        Synatax and URL: [host]/manage/[level, service, power]/[add, del, info, list/del/on, off, reboot]?argvs
        Example: curl '127.0.0.1:8080/manage/level/add/rootfs?mirror.bfsu.edu.cn/lxc-images&debian:bullseye:amd64:default'

    v/version: Print version
    
    h/help: Show this msg again
```

