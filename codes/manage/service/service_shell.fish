function service_shell
    set level "$argv[1]"
    if level_exist "$level"
        if machinectl shell $target
        else
            logger 5 "Unable to shell into $level under $root"
        end
    else
        logger 5 "Level $level is not found under $root"
    end
end