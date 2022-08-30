function service
    switch $argv[1]
        case add
            service_add $argv[2..-1]
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
