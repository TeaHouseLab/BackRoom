function level_exist
    set target $argv[1]
    if jq -er ".[] | select(.uuid==\"$target\")" "$root/level_index.json" &>/dev/null
        set target (jq -r ".[] | select(.uuid==\"$target\") | .uuid" "$root/level_index.json")
        if test -e $root/$target
            return 0
        else
            return 1
        end
    else
        if jq -er ".[] | select(.alias==\"$target\")" "$root/level_index.json" &>/dev/null
            set target (jq -r ".[] | select(.alias==\"$target\") | .uuid" "$root/level_index.json")
            if test -e $root/$target
                return 0
            else
                return 1
            end
        else
            return 1
        end
    end
end