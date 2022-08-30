function service_power
    switch $argv[1]
        case on
            for level in $argv[2..-1]
                if level_exist "$level"
                    if service_exist "$level"
                        if test (jq -er ".[] | select(.uuid==\"$target\") .stat" "$root/level_index.json") = down
                            if systemctl start backroom-$target; and systemctl enable backroom-$target
                                jq -re "[.[] | select(.uuid==\"$target\").stat = \"up\"]" "$root/level_index.json" | sponge "$root/level_index.json"
                                logger 2 "Level $level is up and enabled at startup"
                            else
                                logger 5 "Failed to bring up level $level"
                            end
                        else
                            if test (jq -er ".[] | select(.uuid==\"$target\") .stat" "$root/level_index.json") = up
                                logger 4 "Level $level has already up"
                            else
                                logger 5 "Unknown stat code for level $level"
                                continue
                            end
                        end
                    else
                        service_add $target
                        if systemctl start backroom-$target; and systemctl enable backroom-$target
                            jq -re "[.[] | select(.uuid==\"$target\").stat = \"up\"]" "$root/level_index.json" | sponge "$root/level_index.json"
                            logger 2 "Level $level is up and enabled at startup"
                        else
                            logger 5 "Failed to bring up level $level"
                        end
                    end
                else
                    logger 5 "Level $level is not found under $root"
                end
            end
        case off
            for level in $argv[2..-1]
                if level_exist "$level"
                    if service_exist "$level"
                        if test (jq -er ".[] | select(.uuid==\"$target\") .stat" "$root/level_index.json") = up
                            if systemctl stop backroom-$target; and systemctl disable backroom-$target
                                jq -re "[.[] | select(.uuid==\"$target\").stat = \"down\"]" "$root/level_index.json" | sponge "$root/level_index.json"
                                logger 2 "Level $level is down and disabled at startup"
                            else
                                logger 5 "Failed to put down level $level"
                            end
                        else
                            if test (jq -er ".[] | select(.uuid==\"$target\") .stat" "$root/level_index.json") = down
                                logger 4 "Level $level has already down"
                            else
                                logger 5 "Unknown stat code for level $level"
                                continue
                            end
                        end
                    else
                        logger 4 "Service for level $level is not found"
                    end
                else
                    logger 5 "Level $level is not found under $root"
                end
            end
        case reboot
            for level in $argv[2..-1]
                service_power off $argv[2..-1]
                service_power on $argv[2..-1]
            end
        case '*'
            logger 5 "Option $argv[1] not found at backroom.service.power"
    end
end
