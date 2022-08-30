function setup_network
    if test "$logcat" = debug
        logger 3 "Starting Setup Nat network for levels"
    end
    if systemctl is-active --quiet systemd-networkd
    else
        if test (systemctl list-unit-files 'systemd-networkd*' | wc -l) -gt 3
            sudo systemctl start systemd-networkd
        else
            return 1
        end
    end
end
