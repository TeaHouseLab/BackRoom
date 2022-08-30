function service
    switch $argv[1]
        case add
            switch $argv[2]
                case kvm
                    service_add $argv[3..-1]
                case rootfs
                    service_add_rootfs $argv[3..-1]
            end
        case del
            service_del $argv[2..-1]
        case stat
            service_stat $argv[2..-1]
        case power
            service_power $argv[2..-1]
        case edit
            service_edit $argv[2..-1]
        case '*'
            logger 5 "Option $argv[1] not found at backroom.service"
    end
end
