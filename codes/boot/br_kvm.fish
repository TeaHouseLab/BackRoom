function br_kvm
    set target $argv[1]
    if level_exist "$target"
    else
        logger 5 "Level $target is not found under $root"
        exit 1
    end
    jq -re "(.levels[] | select(.uuid==\"$target\").stat) |= \"up\"" "$root/level_index.json" | sponge "$root/level_index.json"
    set target_port $argv[2]
    set target_core $argv[3]
    set target_mem $argv[4]
    set target_arg $argv[5..-1]
    if test -z "$target_port"
        qemu-system-x86_64 --enable-kvm -smp "$target_core" -m "$target_mem" $target_arg -hda "$root/$target"
    else
        set port_range $target_port
        if echo $port_range | grep -qs -
            set -e port_mapping_tcp
            set -e port_mapping_udp
            set -e port_mapping
            set port_counter 0
            for port_arrary in (seq (echo $port_range | awk -F "-" '{print $1}') (echo $port_range | awk -F "-" '{print $2}'))
                set port_counter (math $port_counter+1)
                set port_mapping_tcp[$port_counter] ",hostfwd=tcp::$port_arrary-:$port_arrary"
                set port_mapping_udp[$port_counter] ",hostfwd=udp::$port_arrary-:$port_arrary"
            end
        else
            if echo $port_range | grep -qs ,
                set -e port_mapping_tcp
                set -e port_mapping_udp
                set -e port_mapping
                set port_counter 0
                for port_arrary in (echo $port_range | string split ,)
                    set port_counter (math $port_counter+1)
                    set port_mapping_tcp[$port_counter] ",hostfwd=tcp::$port_arrary-:$port_arrary"
                    set port_mapping_udp[$port_counter] ",hostfwd=udp::$port_arrary-:$port_arrary"
                end
            else
                set port_mapping_tcp ",hostfwd=tcp::$target_port-:$target_port"
                set port_mapping_udp ",hostfwd=udp::$target_port-:$target_port"
            end
        end
        qemu-system-x86_64 --enable-kvm -smp "$target_core" -m "$target_mem" -nic user$port_mapping_tcp $port_mapping_udp $target_arg -hda "$root/$target"
    end
    jq -re "(.levels[] | select(.uuid==\"$target\").stat) |= \"down\"" "$root/level_index.json" | sponge "$root/level_index.json"
end
