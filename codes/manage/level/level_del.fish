function level_del
    for target in $argv
        if level_exist $target
        mount_utils umount $target
        else
            logger 5 "Level $target is not found under $root"
            continue
        end
    end
end
