function level_list
    switch $argv[1]
        case available
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
            set meta (curl -sL $remote/streams/v1/images.json | jq -r '.products')
            echo $meta | jq -r 'keys | .[]'
        case installed
            jq -er ".[] | .uuid + \" \" + .variant + \" \" + .date" "$root/level_index.json"
        case '*'
            logger 5 "Option $argv[1] not found at backroom.level_list"
    end
end
