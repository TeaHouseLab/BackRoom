function service_edit
    for level in $argv
        if level_exist "$level"
            nano /etc/systemd/system/backroom-$target.service
            systemctl daemon-reload
            logger 2 "Reconfigured level $level at /etc/systemd/system/backroom-$target.service"
        else
            logger 5 "Level $level is not found under $root"
        end
    end
end
