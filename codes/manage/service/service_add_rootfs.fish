function service_add_rootfs
    set pwd (pwd)
    for level in $argv
        if level_exist "$level"
            if service_exist "$level"
                logger 4 "Service for $level is marked as true in index file"
            else
                echo "[Unit]
Description=BackRoom level $target
After=network.target
StartLimitIntervalSec=15
[Service]
User=root
ExecStart=backroom $pwd/$root info enter nspawn boot $target
SyslogIdentifier=backroom-$target
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/backroom-$target.service &>/dev/null
                jq -re "[.[] | select(.uuid==\"$target\").service = \"true\"]" "$root/level_index.json" | sponge "$root/level_index.json"
                logger 2 "Service has been created for level $level at /etc/systemd/system/backroom-$target.service"
            end
        else
            logger 5 "Level $level is not found under $root"
        end
    end
end
