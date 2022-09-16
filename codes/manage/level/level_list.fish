function level_list
    switch $argv[1]
        case available
            set remote $argv[2]
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
            set meta (curl -sL $remote/streams/v1/images.json | jq -r '.products')
            echo $meta | jq -r keys
        case installed
            switch $argv[2]
                case size
                    for level in (jq -er '.levels[].uuid' "$root/level_index.json")
                        set alias (jq -er ".levels[] | select(.uuid==\"$level\").alias" "$root/level_index.json")
                        set variant (jq -er ".levels[] | select(.uuid==\"$level\").variant" "$root/level_index.json")
                        set size (du -sh $root/$level | awk '{ print $1 }')
                        echo '{}' | jq -er ". + {\"uuid\": \"$level\", \"variant\": \"$variant\", \"alias\": \"$alias\", \"size\": \"$size\"}"
                    end
                case '*'
                    jq -er '[.levels[] | {"uuid": .uuid, "variant": .variant, "alias": .alias}]' "$root/level_index.json"
            end
        case '*'
            level_list installed
    end
end
