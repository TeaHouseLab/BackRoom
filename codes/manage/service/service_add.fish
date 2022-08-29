function service_add
    for target in $argv
        if test -d $root/$target
        else
            if test -e /etc/systemd/system/backroom-$target
            else
                logger 5 ""
            end
        end
    end
end
