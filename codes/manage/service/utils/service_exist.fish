function service_exist
    set target $argv[1]
    if level_exist "$target"
        if jq -er ".levels[] | select(.uuid==\"$target\") | select(.service==\"false\")" "$root/level_index.json" &>/dev/null
            if test -e /etc/systemd/system/backroom-$target.service
                return 0
            else
                return 1
            end
        else
            return 0
        end
    else
        return 1
    end
end
