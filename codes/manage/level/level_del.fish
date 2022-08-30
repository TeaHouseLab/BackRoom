function level_del
    for level in $argv
        if level_exist "$level"
            mount_utils umount "$target"
            service_power off "$target"
            service_del "$target"
            if rm -rf "$root/$target"
                jq -er "del(.[] | select(.uuid == \"$target\"))" "$root/level_index.json"
                logger 2 "Level $level at "$root/$target" has been destroyed"
            else
                logger 5 "Failed to destroy level $level"
            end
        else
            logger 5 "Level $level is not found under $root"
            continue
        end
    end
end
