function service_del
    for level in $argv
        if level_exist "$level"
            if service_exist "$level"
                rm /etc/systemd/system/backroom-$target.service
                jq -re "(.levels[] | select(.uuid==\"$target\").service) |= \"false\"" "$root/level_index.json" | sponge "$root/level_index.json"
                logger 2 "Service file for level $level has been removed from /etc/systemd/system/backroom-$target.service"
            else
                logger 5 "Service file for level $level is not found"
            end
        else
            logger 5 "Level $level is not found under $root"
        end
    end
end
