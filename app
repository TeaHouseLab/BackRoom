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
    
    manage: Manage backroom levels (Aka. setup/configure/manage a machine)
        Subcommand: [add, del, info, list, alias]
        
        manage add: Create new levels from remote lxc repo
            Syntax: manage add [remote - http(s) only] [targets]
            Example: backroom ./test debug manage level add https://mirrors.bfsu.edu.cn/lxc-images ubuntu:xenial:s390x:default ubuntu:xenial:amd64:default
            
        manage del: Destroy levels
            Syntax: manage del [targets]
            (!)Target has to be specific uuid of the level
            Example: backroom ./test debug manage level del f6c23a26881f4bf8bf9aa2af19d38548 a0d9300af25b473e95198427b2213008
            
        manage info: Print the info of levels
            Syntax: manage info [targets]
            Example: backroom ./test debug manage level info a0d9300af25b473e95198427b2213008
            
        manage alias: Set an alias for a level
            Syntax: manage alias [target-uuid] [alias name]
            Example: backroom ./test debug manage level alias a0d9300af25b473e95198427b2213008 Earth
            
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

end
function service_del

end
function service_add
    for target in $argv
        if test -d $root/$target
        else
            if test -e /etc/systemd/system/backroom-$target
            else
                logger 5 ""
            end
        end
    end
end

function level_del

end
function level_list

end
function level_info

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
            echo $containername > $root/$target/etc/hostname
            echo 127.0.0.1  $containername >> $root/$target/etc/hosts
            cp -f --remove-destination /etc/resolv.conf $root/$target/etc/resolv.conf"
    else
        sh -c "echo 'safety:x:1000:1000:safety,,,:/home/safety:/bin/sh' >> $root/$target/etc/passwd
            echo 'safety:x:1000:' >> $root/$target/etc/group
            echo 'safety:!:0:0:99999:7:::' >> $root/$target/etc/shadow
            mkdir -p $root/$target/home/safety
            rm -f $root/$target/etc/hostname
            echo $containername > $root/$target/etc/hostname
            echo 127.0.0.1  $containername >> $root/$target/etc/hosts
            cp -f --remove-destination /etc/resolv.conf $root/$target/etc/resolv.conf" &>/dev/null
    end
    
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
            exit 128
        end
    end
    if sudo -E curl --progress-bar -L -o "$root/.package/$target.level" "$remote/$path"
        if test "$(sha256sum $root/.package/$target.level | awk -F ' ' '{print $1}')"
            logger 2 "Level package $target checked"
        else
            logger 4 "Level package $target check sha256 failed"
            set check failed
        end
    end
end

function level_add
    set -x remote $argv[1]
    set -x targets $argv[2..-1]
    set -x check
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
        exit 128
    end
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
            exit 128
        end
    end
    for target in $targets
        level_seed $target
        if test "$check" = failed
            continue
        end
        set uuid (cat /proc/sys/kernel/random/uuid | sed 's/-//g')
        mkdir $uuid
        tar --force-local -xf "$root/.package/$target.level" -C "$root/$uuid"
        level_spawn $uuid
        if test "$check" = failed
            continue
        else
            jq ". + [{\"uuid\": \"$uuid\" ,\"variant\": \"$target\", \"alias\": \"\"}]" "$root/level_index.json" | sponge "$root/level_index.json"
            logger 2 "Level $uuid spawned"
        end
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
    end
end

function nspawn

end
function mount_utils

end
function chroot

end
function utils

end
function api

end
echo Build_Time_UTC=2022-08-29_13:13:43
set -x prefix "[BackRoom]"
set -x codename Joshua
set -x ver 1
set -x root $argv[1]
set -x logcat $argv[2]
checkdependence jq curl
if test -e $root
    if test -d $root
        if test -w $root; and test -r $root
        else
            logger 5 "root => $root is not Readable/Writable"
            exit 128
        end
    else
        logger 5 "root => $root is not a diretory file"
        exit 128
    end
else
    logger 5 "root => $root is not found"
    exit 128
end
switch $argv[3]
    case enter
        switch $argv[4]
            case nspawn
            case chroot
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
