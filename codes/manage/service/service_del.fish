function service_del
    for target in $argv
        if level_exist $target
            if service_exist $target
                rm /etc/systemd/system/backroom-$target.service
                jq -re ".[] | select(.uuid==\"$target\") .service = \"false\"" "$root/level_index.json" | sponge "$root/level_index.json"
                logger 2 "Service file for level $target has been removed"
            else
                logger 5 "Service file for level $target is not found"
            end
        else
            logger 5 "Level $target is not found under $root"
        end
    end
end
