function level_add_rootfs
    set -x remote $argv[1]
    set -x targets $argv[2..-1]
    set -x timestamp (date -u +"%Y-%m-%d-%H:%M:%S")
    set -x check
    if test -z $remote
        if test -z (jq -re ".remote " "$root/level_index.json")
            logger 5 "No remote configured"
            exit 1
        else
            if test "$logcat" = debug
                logger 3 "Remote set from storage"
            end
            set remote (jq -re ".remote " "$root/level_index.json")
        end
    else
        if test -z (jq -re ".remote " "$root/level_index.json")
            jq -re ".remote |= \"$remote\"" "$root/level_index.json" | sponge "$root/level_index.json"
            if test "$logcat" = debug
                logger 3 "Remote stored"
            end
        end
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
            return 1
            continue
        end
        set uuid (cat /proc/sys/kernel/random/uuid | sed 's/-//g')
        mkdir $uuid
        tar --force-local -xf "$root/.package/$target.level" -C "$root/$uuid"
        jq ".levels |= . + [{\"uuid\": \"$uuid\" ,\"variant\": \"$target\",\"type\": \"rootfs\" , \"alias\": \"\", \"date\": \"$timestamp\", \"service\": \"false\", \"stat\": \"down\"}]" "$root/level_index.json" | sponge "$root/level_index.json"
        if level_spawn $uuid
            logger 2 "Level $uuid spawned"
        else
            continue
        end
    end
end
