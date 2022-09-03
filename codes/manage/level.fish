function level
    switch $argv[1]
        case add
            switch $argv[2]
                case kvm
                    level_add_kvm $argv[3..-1]
                case rootfs
                    level_add_rootfs $argv[3..-1]
            end
        case del
            level_del $argv[2..-1]
        case info
            level_info $argv[2..-1]
        case tar
            level_tar $argv[2..-1]
        case list
            level_list $argv[2..-1]
        case alias
            level_alias $argv[2..-1]
        case '*'
            logger 5 "Option $argv[1] not found at backroom.level"
    end
end
