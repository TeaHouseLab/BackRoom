function service_stat
    for level in $argv
        if level_exist "$level"
            if service_exist "$level"
                set power_stat (jq -re ".levels[] | select(.uuid==\"$target\").stat" "$root/level_index.json")
                if test "$power_stat" = up
                    set_color green
                    echo "$level is up"
                    set_color normal
                else
                    if test "$power_stat" = down
                        set_color red
                        echo "$level is down"
                        set_color normal
                    else
                        set_color yellow
                        echo "$level is in a unknown status -> $power_stat"
                        set_color normal
                    end
                end
            else
                logger 5 "Service file for level $target is not found"
            end
        else
            logger 5 "Level $target is not found under $root"
        end
    end
end
