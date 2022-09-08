function level_add_kvm
    set seed $argv[1]
    set uuid (cat /proc/sys/kernel/random/uuid | sed 's/-//g')
    set timestamp (date -u +"%Y-%m-%d-%H:%M:%S")
    if file $seed | grep -qs Image
        if cp $seed $uuid
            jq ".levels |= . + [{\"uuid\": \"$uuid\" ,\"variant\": \"kvm_machine\",\"type\": \"disk\" , \"alias\": \"\", \"date\": \"$timestamp\", \"service\": \"false\", \"stat\": \"down\"}]" "$root/level_index.json" | sponge "$root/level_index.json"
            logger 2 "Level $uuid spawned"
        else
            logger 5 "Failed to spawn level from $seed"
        end
    else
        logger 5 "This is not a disk image"
        return 1
    end
end
