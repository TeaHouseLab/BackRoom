function level_info
    for level in $argv
        if level_exist "$level"
            jq -er ".levels[] | select(.uuid==\"$target\")" "$root/level_index.json"
        else
            logger 5 "Level $level is not found under $root"
        end
    end
end
