function br_nspawn
    set target $argv[2]
    if level_exist "$target"
    else
        logger 5 "Level $target is not found under $root"
        exit 1
    end
    jq -re "[.[] | select(.uuid==\"$target\").stat = \"up\"]" "$root/level_index.json" | sponge "$root/level_index.json"
    switch $argv[1]
        case exec
            sudo systemd-nspawn --resolv-conf=off -q -D "$root/$target" $argv[2..-1]
        case boot
            if setup_network
            else
                logger 5 "Failed to setup network"
                exit 1
            end
            set target_port $argv[3]
            if test -z "$target_port"
                sudo systemd-nspawn --resolv-conf=off -bnq -D "$root/$target"
            else
                set port_range $target_port
                if echo $port_range | grep -qs -
                    set -e port_mapping_tcp
                    set -e port_mapping_udp
                    set -e port_mapping
                    set port_counter 0
                    for port_arrary in (seq (echo $port_range | awk -F "-" '{print $1}') (echo $port_range | awk -F "-" '{print $2}'))
                        set port_counter (math $port_counter+1)
                        set port_mapping_tcp[$port_counter] "-ptcp:$port_arrary"
                        set port_mapping_udp[$port_counter] "-pudp:$port_arrary"
                    end
                else
                    if echo $port_range | grep -qs ,
                        set -e port_mapping_tcp
                        set -e port_mapping_udp
                        set -e port_mapping
                        set port_counter 0
                        for port_arrary in (echo $port_range | string split ,)
                            set port_counter (math $port_counter+1)
                            set port_mapping_tcp[$port_counter] "-ptcp:$port_arrary"
                            set port_mapping_udp[$port_counter] "-pudp:$port_arrary"
                        end
                    else
                        set port_mapping_tcp "-ptcp:$target_port"
                        set port_mapping_udp "-pudp:$target_port"
                    end
                end
                sudo systemd-nspawn --resolv-conf=off $port_mapping_tcp $port_mapping_udp -bnq -D "$root/$target"
            end
        case '*'
            logger 5 "Option $argv[1] not found at backroom.nspawn"
            return 1
    end
    jq -re "[.[] | select(.uuid==\"$target\").stat = \"down\"]" "$root/level_index.json" | sponge "$root/level_index.json"
end
