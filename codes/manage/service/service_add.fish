function service_add
    for target in $argv
        if level_exist $target
            if service_exist $target
                logger 4 "Service for $target is marked as true in index file"
            else
                echo "[Unit]
Description=BackRoom level $target
After=network.target
StartLimitIntervalSec=15
[Service]
User=root
ExecStart=backroom $root info enter nspawn boot $target
SyslogIdentifier=backroom-$target
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/backroom-$target.service &>/dev/null
                jq -re ".[] | select(.uuid==\"$target\") .service = \"true\"" "$root/level_index.json" | sponge "$root/level_index.json"
            end
        else
            logger 5 "Level $target is not found under $root"
        end
    end
end
