#!/usr/bin/env fish

function configure
    sed -n "/$argv[1]=/"p "$argv[2]" | sed "s/$argv[1]=//g"
end
function logger-warn
  set_color magenta
  echo "$prefix ! $argv[1..-1]"
  set_color normal
end
function logger-error
  set_color red
  echo "$prefix x $argv[1..-1]"
  set_color normal
end
function logger-info-start
  set_color normal
  echo "$prefix + $argv[1..-1]"
  set_color normal
end
function logger-info-end
  set_color normal
  echo "$prefix - $argv[1..-1]"
  set_color normal
end
function logger-debug
  set_color yellow
  echo "$prefix ? $argv[1..-1]"
  set_color normal
end
function logger-success
  set_color green
  echo "$prefix √ $argv[1..-1]"
  set_color normal
end
function logger -d "a lib to print msg quickly"
switch $argv[1]
case 0
  logger-info-start $argv[2..-1]
case 1
  logger-info-end $argv[2..-1]
case 2
  logger-success $argv[2..-1]
case 3
  logger-debug $argv[2..-1]
case 4
  logger-warn $argv[2..-1]
case 5
  logger-error $argv[2..-1]
end
end

function help_echo
 echo '
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
                Synatax: service power [on/off] [targets]
                Example: backroom ./test debug manage service power on Earth f6c23a26881f4bf8bf9aa2af19d38548

            service stat: Print stats of levels in index
                Synatax: service stat Earth
                Example: backroom ./test debug manage service stat Earth
            
    host: Run backroom as an daemon, provide custom api for easier hosting in OpenVZ style
    
    v/version: Print version
    
    h/help: Show this msg again'
end

function checkdependence
set 34ylli8_deps_ok 1
for 34ylli8_deps in $argv
    if command -q -v $34ylli8_deps
    else
        set 34ylli8_deps_ok 0
        if test -z "$34ylli8_dep_lost"
            set 34ylli8_deps_lost "$34ylli8_deps $34ylli8_deps_lost"
        else
            set 34ylli8_deps_lost "$34ylli8_deps"
        end
    end
end
if test "$34ylli8_deps_ok" -eq 0
    set_color red
    echo "$prefix [error] Please install "$34ylli8_deps_lost"to run this program"
    set_color normal
    exit
end
end
function checknetwork
  if curl -s -L $argv[1] | grep -q $argv[2]
  else
    set_color red
    echo "$prefix [error] [checknetwork] check failed - check your network connection"
    set_color normal
  end
end
function dir_exist
  if test -d $argv[1]
  else
    set_color red
    echo "$prefix [error] [checkdir] check failed - dir $argv[1] doesn't exist,going to makr one"
    set_color normal
    mkdir $argv[1]
  end
end
function list_menu
ls $argv | sed '\~//~d'
end

function service_stat
    for level in $argv
        if level_exist "$level"
            if service_exist "$level"
                set power_stat (jq -re ".[] | select(.uuid==\"$target\") .stat" "$root/level_index.json")
                if test "$power_stat" = up
                    set_color green
                    echo "$level is up"
                    set_color normal
                else
                    if test "$power_stat" = down
                        set_color green
                        echo "$level is down"
                        set_color normal
                    else
                        set_color yellow
                        echo "$level is in a unknown status -> $power_stat"
                        set_color normal
                    end
                end
            else
                logger 5 "Service file for level $target is not found"
            end
        else
            logger 5 "Level $target is not found under $root"
        end
    end
end

function service_edit
    for level in $argv
        if level_exist "$level"
            nano /etc/systemd/system/backroom-$target.service
            systemctl daemon-reload
            logger 2 "Reconfigured level $level at /etc/systemd/system/backroom-$target.service"
        else
            logger 5 "Level $level is not found under $root"
        end
    end
end

function service_del
    for level in $argv
        if level_exist "$level"
            if service_exist "$level"
                rm /etc/systemd/system/backroom-$target.service
                jq -re "[.[] | select(.uuid==\"$target\").service = \"false\"]" "$root/level_index.json" | sponge "$root/level_index.json"
                logger 2 "Service file for level $level has been removed from /etc/systemd/system/backroom-$target.service"
            else
                logger 5 "Service file for level $level is not found"
            end
        else
            logger 5 "Level $level is not found under $root"
        end
    end
end

function service_power
    switch $argv[1]
        case on
            for level in $argv[2..-1]
                if level_exist "$level"
                    if service_exist "$level"
                        if test (jq -er ".[] | select(.uuid==\"$target\") .stat" "$root/level_index.json") = down
                            if systemctl start backroom-$target; and systemctl enable backroom-$target
                                jq -re "[.[] | select(.uuid==\"$target\").stat = \"up\"]" "$root/level_index.json" | sponge "$root/level_index.json"
                                logger 2 "Level $level is up and enabled at startup"
                            else
                                logger 5 "Failed to bring up level $level"
                            end
                        else
                            if test (jq -er ".[] | select(.uuid==\"$target\") .stat" "$root/level_index.json") = up
                                logger 4 "Level $level has already up"
                            else
                                logger 5 "Unknown stat code for level $level"
                                continue
                            end
                        end
                    else
                        service_add $target
                        if systemctl start backroom-$target; and systemctl enable backroom-$target
                            jq -re "[.[] | select(.uuid==\"$target\").stat = \"up\"]" "$root/level_index.json" | sponge "$root/level_index.json"
                            logger 2 "Level $level is up and enabled at startup"
                        else
                            logger 5 "Failed to bring up level $level"
                        end
                    end
                else
                    logger 5 "Level $level is not found under $root"
                end
            end
        case off
            for level in $argv[2..-1]
                if level_exist "$level"
                    if service_exist "$level"
                        if test (jq -er ".[] | select(.uuid==\"$target\") .stat" "$root/level_index.json") = up
                            if systemctl stop backroom-$target; and systemctl disable backroom-$target
                                jq -re "[.[] | select(.uuid==\"$target\").stat = \"down\"]" "$root/level_index.json" | sponge "$root/level_index.json"
                                logger 2 "Level $level is down and disabled at startup"
                            else
                                logger 5 "Failed to put down level $level"
                            end
                        else
                            if test (jq -er ".[] | select(.uuid==\"$target\") .stat" "$root/level_index.json") = down
                                logger 4 "Level $level has already down"
                            else
                                logger 5 "Unknown stat code for level $level"
                                continue
                            end
                        end
                    else
                        logger 4 "Service for level $level is not found"
                    end
                else
                    logger 5 "Level $level is not found under $root"
                end
            end
        case reboot
            for level in $argv[2..-1]
                service_power off $argv[2..-1]
                service_power on $argv[2..-1]
            end
        case '*'
            logger 5 "Option $argv[1] not found at backroom.service.power"
    end
end

function service_add
    set pwd (pwd)
    for level in $argv
        if level_exist "$level"
            if service_exist "$level"
                logger 4 "Service for $level is marked as true in index file"
            else
                echo "[Unit]
Description=BackRoom level $target
After=network.target
StartLimitIntervalSec=15
[Service]
User=root
ExecStart=backroom $pwd/$root info enter nspawn boot $target
SyslogIdentifier=backroom-$target
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/backroom-$target.service &>/dev/null
                jq -re "[.[] | select(.uuid==\"$target\").service = \"true\"]" "$root/level_index.json" | sponge "$root/level_index.json"
                logger 2 "Service has been created for level $level at /etc/systemd/system/backroom-$target.service"
            end
        else
            logger 5 "Level $level is not found under $root"
        end
    end
end

function service_exist
    set target $argv[1]
    if level_exist "$target"
        if jq -er ".[] | select(.uuid==\"$target\") | select(.service==\"false\")" "$root/level_index.json" &>/dev/null
            if test -e /etc/systemd/system/backroom-$target.service
                return 0
            else
                return 1
            end
        else
            return 0
        end
    else
        return 1
    end
end

function level_del
    for level in $argv
        if level_exist "$level"
            mount_utils umount "$target"
            service_power off "$target"
            service_del "$target"
            if rm -rf "$root/$target"
                jq -er "del(.[] | select(.uuid == \"$target\"))" "$root/level_index.json" | sponge "$root/level_index.json"
                logger 2 "Level $level at "$root/$target" has been destroyed"
            else
                logger 5 "Failed to destroy level $level"
            end
        else
            logger 5 "Level $level is not found under $root"
            continue
        end
    end
end

function level_list
    set remote $argv[2]
    if test -z $remote
        logger 5 "No remote configured"
        exit 1
    end
    if test "$logcat" = debug
        logger 3 "Set remote lxc repo to $remote"
        logger 3 "Testing connectivity to remote"
        logger 3 "Test if index file is available in $root"
    end
    if test "$(curl -sL $remote/streams/v1/images.json | jq -r .content_id)" = images
        if test "$logcat" = debug
            logger 3 "Connected to remote"
        end
    else
        logger 5 "This remote repo does not contain lxc images or it's down currently"
        exit 1
    end
    switch $argv[1]
        case available
            set meta (curl -sL $remote/streams/v1/images.json | jq -r '.products')
            echo $meta | jq -r 'keys | .[]'
        case installed
            jq -er ".[] | .uuid + \" \" + .variant + \" \" + .date" "$root/level_index.json"
        case '*'
            logger 5 "Option $argv[1] not found at backroom.level_list"
    end
end

function level_info
    for level in $argv
        if level_exist "$level"
            jq -er ".[] | select(.uuid==\"$target\")" "$root/level_index.json"
        else
            logger 5 "Level $level is not found under $root"
        end
    end
end

function level_spawn
    set target $argv[1]
    if test "$logcat" = debug
        logger 3 "Spawning $target"
        sh -c "echo 'safety:x:1000:1000:safety,,,:/home/safety:/bin/sh' >> $root/$target/etc/passwd
            echo 'safety:x:1000:' >> $root/$target/etc/group
            echo 'safety:!:0:0:99999:7:::' >> $root/$target/etc/shadow
            mkdir -p $root/$target/home/safety
            rm -f $root/$target/etc/hostname
            echo $target > $root/$target/etc/hostname
            echo 127.0.0.1  $target >> $root/$target/etc/hosts
            cp -f --remove-destination /etc/resolv.conf $root/$target/etc/resolv.conf"
    else
        sh -c "echo 'safety:x:1000:1000:safety,,,:/home/safety:/bin/sh' >> $root/$target/etc/passwd
            echo 'safety:x:1000:' >> $root/$target/etc/group
            echo 'safety:!:0:0:99999:7:::' >> $root/$target/etc/shadow
            mkdir -p $root/$target/home/safety
            rm -f $root/$target/etc/hostname
            echo $target > $root/$target/etc/hostname
            echo 127.0.0.1  $target >> $root/$target/etc/hosts
            cp -f --remove-destination /etc/resolv.conf $root/$target/etc/resolv.conf" &>/dev/null
    end
    if [ "$logcat" = debug ]
        logger 3 "Configuring $target"
        br_chroot $target /bin/sh -c '/bin/chown -R safety:safety /home/safety
            /bin/chmod -R 755 /home/safety & echo "safety    ALL=(ALL:ALL) ALL" >> /etc/sudoers
            echo "0d7882da60cc3838fabc4efc62908206" > /etc/machine-id
            (crontab -l 2>/dev/null; echo @reboot ip link set host0 name eth0) | crontab -'
    else
        br_chroot $target /bin/sh -c '/bin/chown -R safety:safety /home/safety
            /bin/chmod -R 755 /home/safety & echo "safety    ALL=(ALL:ALL) ALL" >> /etc/sudoers
            echo "0d7882da60cc3838fabc4efc62908206" > /etc/machine-id
            (crontab -l 2>/dev/null; echo @reboot ip link set host0 name eth0) | crontab -' &>/dev/null
    end
    return 0
end
function level_seed
    set target $argv[1]
    set meta (curl -sL $remote/streams/v1/images.json | jq -r '.products')
    set latest (echo $meta | jq -r ".[\"$target\"].versions|keys|.[]" | tail -n1)
    set path (echo $meta | jq -r ".[\"$target\"].versions|.[\"$latest\"].items |.[\"root.tar.xz\"].path")
    if echo "$path" | grep -qs null
        logger 5 "Target does not exist in remote repo"
    else
        set sha256 (echo $meta | jq -r ".[\"$target\"].versions|.[\"$latest\"].items |.[\"root.tar.xz\"].sha256")
    end
    if test "$logcat" = debug
        logger 3 "Testing if package folder exist"
    end
    if test -d "$root/.package"
        if test "$logcat" = debug
            logger 3 "Package folder is existed"
        end
    else
        logger 4 "Package folder is not existed, trying to create it"
        if mkdir -p "$root/.package"
        else
            logger 5 "Can not create the package cache folder"
            exit 1
        end
    end
    if test -e "$root/.package/$target.level"
        if test "$(sha256sum $root/.package/$target.level | awk -F ' ' '{print $1}')"
            logger 2 "Level package $target checked, using cached package"
            return 0
        else
            logger 4 "Level package $target check sha256 failed"
            rm "$root/.package/$target.level"
            level_seed $target
        end
    else
        if sudo -E curl --progress-bar -L -o "$root/.package/$target.level" "$remote/$path"
            if test "$(sha256sum $root/.package/$target.level | awk -F ' ' '{print $1}')"
                logger 2 "Level package $target checked"
                return 0
            else
                logger 4 "Level package $target check sha256 failed"
                return 1
            end
        end
    end
end

function level_exist
    set target $argv[1]
    if jq -er ".[] | select(.uuid==\"$target\")" "$root/level_index.json" &>/dev/null
        set target (jq -r ".[] | select(.uuid==\"$target\") | .uuid" "$root/level_index.json")
        if test -d $root/$target
            return 0
        else
            return 1
        end
    else
        if jq -er ".[] | select(.alias==\"$target\")" "$root/level_index.json" &>/dev/null
            set target (jq -r ".[] | select(.alias==\"$target\") | .uuid" "$root/level_index.json")
            if test -d $root/$target
                return 0
            else
                return 1
            end
        else
            return 1
        end
    end
end
function level_add
    set -x remote $argv[1]
    set -x targets $argv[2..-1]
    set -x timestamp (date -u +"%Y-%m-%d %H:%M:%S")
    set -x check
    if test -z $remote
        logger 5 "No remote configured"
        exit 1
    end
    if test "$logcat" = debug
        logger 3 "Set remote lxc repo to $remote"
        logger 3 "Testing connectivity to remote"
        logger 3 "Test if index file is available in $root"
    end
    if test "$(curl -sL $remote/streams/v1/images.json | jq -r .content_id)" = images
        if test "$logcat" = debug
            logger 3 "Connected to remote"
        end
    else
        logger 5 "This remote repo does not contain lxc images or it's down currently"
        exit 1
    end
    for target in $targets
        if level_seed $target
        else
            continue
        end
        set uuid (cat /proc/sys/kernel/random/uuid | sed 's/-//g')
        mkdir $uuid
        tar --force-local -xf "$root/.package/$target.level" -C "$root/$uuid"
        jq ". + [{\"uuid\": \"$uuid\" ,\"variant\": \"$target\", \"alias\": \"\", \"date\": \"$timestamp\", \"service\": \"false\", \"stat\": \"down\"}]" "$root/level_index.json" | sponge "$root/level_index.json"
        if level_spawn $uuid
            logger 2 "Level $uuid spawned"
        else
            continue
        end
    end
end

function level_alias
    set target $argv[1]
    set alias $argv[2]
    if level_exist $target
        if jq -re "[.[] | select(.uuid==\"$target\").alias = \"$alias\"]" "$root/level_index.json" | sponge "$root/level_index.json"
            logger 2 "Set alias $alias for level $target"
        else
            logger 5 "Failed to set alias for level $target"
        end
    else
        logger 5 "Level $target is not found under $root"
    end
end

function service
    switch $argv[1]
        case add
            service_add $argv[2..-1]
        case del
            service_del $argv[2..-1]
        case stat
            service_stat $argv[2..-1]
        case power
            service_power $argv[2..-1]
        case edit
            service_edit $argv[2..-1]
        case '*'
            logger 5 "Option $argv[1] not found at backroom.service"
        end
end

function level
    switch $argv[1]
        case add
            level_add $argv[2..-1]
        case del
            level_del $argv[2..-1]
        case info
            level_info $argv[2..-1]
        case list
            level_list $argv[2..-1]
        case alias
            level_alias $argv[2..-1]
        case '*'
            logger 5 "Option $argv[1] not found at backroom.level"
    end
end

function br_chroot
    set target $argv[1]
    if level_exist "$target"
    else
        logger 5 "Level $target is not found under $root"
        exit 1
    end
    mount_utils mount "$target"
    logger 0 "Entering level $target"
    chroot "$root/$target" $argv[2..-1]
    mount_utils umount "$target"
end

function br_nspawn
    set target $argv[2]
    set target_port $argv[3]
    if level_exist "$target"
    else
        logger 5 "Level $target is not found under $root"
        exit 1
    end
    jq -re "[.[] | select(.uuid==\"$target\").stat = \"up\"]" "$root/level_index.json" | sponge "$root/level_index.json"
    switch $argv[1]
        case exec
            sudo systemd-nspawn --resolv-conf=off -q -D "$root/$target" $argv[2..-1]
        case boot
            if setup_network
            else
                logger 5 "Failed to setup network"
                exit 1
            end
            if test -z target_port
                sudo systemd-nspawn --resolv-conf=off -bnq -D "$root/$target"
            else
                set port_range $target_port
                if echo $port_range | grep -qs -
                    set -e port_mapping_tcp
                    set -e port_mapping_udp
                    set -e port_mapping
                    set port_counter 0
                    for port_arrary in (seq (echo $port_range | awk -F "-" '{print $1}') (echo $port_range | awk -F "-" '{print $2}'))
                        set port_counter (math $port_counter+1)
                        set port_mapping_tcp[$port_counter] "-ptcp:$port_arrary"
                        set port_mapping_udp[$port_counter] "-pudp:$port_arrary"
                    end
                else
                    if echo $port_range | grep -qs ,
                        set -e port_mapping_tcp
                        set -e port_mapping_udp
                        set -e port_mapping
                        set port_counter 0
                        for port_arrary in (echo $port_range | string split ,)
                            set port_counter (math $port_counter+1)
                            set port_mapping_tcp[$port_counter] "-ptcp:$port_arrary"
                            set port_mapping_udp[$port_counter] "-pudp:$port_arrary"
                        end
                    else
                        set port_mapping_tcp "-ptcp:$target_port"
                        set port_mapping_udp "-pudp:$target_port"
                    end
                end
                sudo systemd-nspawn --resolv-conf=off $port_mapping_tcp $port_mapping_udp -bnq -D "$root/$target"
            end
        case '*'
            logger 5 "Option $argv[1] not found at backroom.nspawn"
            return 1
    end
    jq -re "[.[] | select(.uuid==\"$target\").stat = \"down\"]" "$root/level_index.json" | sponge "$root/level_index.json"
end

function mount_utils
    set target $argv[2]
    function mount_rw
        for mount_target in $argv
            if test "$logcat" = debug
                logger 3 "Mounting $mount_target to $root/$target$mount_target"
            end
            if grep -qs "$root/$target$mount_target" /proc/mounts
            else
                mount -o bind,rw "$mount_target" "$root/$target$mount_target"
            end
        end
    end
    function umount_rw
        for umount_target in $argv
            if test "$logcat" = debug
                logger 3 "Unmounting $umount_target $root/$target$umount_target"
            end
            if grep -qs "$root/$target$umount_target" /proc/mounts
                umount -l "$root/$target$umount_target"
            end
            if grep -qs /dev/pts /proc/mounts
            else
                mount devpts /dev/pts -t devpts
            end
        end
    end
    switch $argv[1]
        case mount
            mount_rw /dev /dev/pts /proc /sys
        case umount
            umount_rw /dev /dev/pts /proc /sys
        case '*'
            logger 5 "Option $argv[1] not found at backroom.chroot.mount_utils"
            return 1
    end
end

function setup_network
    if test "$logcat" = debug
        logger 3 "Starting Setup Nat network for levels"
    end
    if systemctl is-active --quiet systemd-networkd
    else
        if test (systemctl list-unit-files 'systemd-networkd*' | wc -l) -gt 3
            sudo systemctl start systemd-networkd
        else
            return 1
        end
    end
end

function utils

end
function api

end
echo Build_Time_UTC=2022-08-30_07:33:49
set -x prefix "[BackRoom]"
set -x codename Joshua
set -x ver 1
set -x target
set -x root $argv[1]
set -x logcat $argv[2]
checkdependence jq curl sponge nano
if test -e $root
    if test -d $root
        if test -w $root; and test -r $root
            if test -e "$root/level_index.json"
                if test "$logcat" = debug
                    logger 3 "Index is available"
                end
            else
                if echo "[]" >"$root/level_index.json"
                    if test "$logcat" = debug
                        logger 3 "Index is available"
                    end
                else
                    logger 5 "Can not create index file in $root"
                    exit 1
                end
            end
        else
            logger 5 "root => $root is not Readable/Writable"
            exit 1
        end
    else
        logger 5 "root => $root is not a diretory file"
        exit 1
    end
else
    logger 5 "root => $root is not found"
    exit 1
end
switch $argv[3]
    case enter
        switch $argv[4]
            case nspawn
                br_nspawn $argv[5..-1]
            case chroot
                br_chroot $argv[5..-1]
        end
    case manage
        switch $argv[4]
            case service
                service $argv[5..-1]
            case level
                level $argv[5..-1]
        end
    case host
        api $argv[4..-1]
    case v version
        logger 1 "$codename@build$version"
    case h help '*'
        help_echo
end
