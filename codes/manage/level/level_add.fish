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
