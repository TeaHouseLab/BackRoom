function br_chroot
    set target $argv[1]
    if jq -r ".[] | select(.uuid==\"$target\")" "$root/level_index.json"
        set target (jq -r ".[] | select(.uuid==\"$target\") | .uuid" "$root/level_index.json")
    else
        if jq -r ".[] | select(.alias==\"$target\")" "$root/level_index.json"
            set target (jq -r ".[] | select(.alias==\"$target\") | .uuid" "$root/level_index.json")
        else
            logger 5 "This level is not exist"
            exit 128
        end
    end
    mount_utils
end
