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
