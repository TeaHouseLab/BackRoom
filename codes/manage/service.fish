function service
    switch $argv[1]
        case add
            service_add $argv[2..-1]
        case del
            service_del $argv[2..-1]
        case stat
            service_stat $argv[2..-1]
    end
end
