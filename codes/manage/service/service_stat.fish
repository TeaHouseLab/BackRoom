function service_stat
    for target in $argv
        if level_exist $target
            
        else
            logger 5 "Level $target is not found under $root"
        end
    end
end
