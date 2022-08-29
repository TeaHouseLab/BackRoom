function level_add
    set -x remote $argv[1]
    set -x targets $argv[2..-1]
    set -x check
    if test "$logcat" = debug
        logger 3 "Set remote lxc repo to $remote"
        logger 3 "Testing connectivity to remote"
    end
    if test "$(curl -sL $remote/streams/v1/images.json | jq -r .content_id)" = "images"
        if test "$logcat" = debug
            logger 3 "Connected to remote"
        end
    else
        logger 5 "This remote repo does not contain lxc images or it's down currently"
        exit 128
    end
    for target in $targets
        level_seed $target
        if test "$check" = "failed"
            continue
        end
        set uuid (cat /proc/sys/kernel/random/uuid | sed 's/-//g')
    end
end
