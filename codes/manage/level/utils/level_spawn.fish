function level_spawn
    set target $argv[1]
    if test "$logcat" = debug
        logger 3 "Spawning $target"
        sh -c "echo 'safety:x:1000:1000:safety,,,:/home/safety:/bin/sh' >> $root/$target/etc/passwd
            echo 'safety:x:1000:' >> $root/$target/etc/group
            echo 'safety:!:0:0:99999:7:::' >> $root/$target/etc/shadow
            mkdir -p $root/$target/home/safety
            rm -f $root/$target/etc/hostname
            echo $target > $root/$target/etc/hostname
            echo 127.0.0.1  $target >> $root/$target/etc/hosts
            cp -f --remove-destination /etc/resolv.conf $root/$target/etc/resolv.conf"
    else
        sh -c "echo 'safety:x:1000:1000:safety,,,:/home/safety:/bin/sh' >> $root/$target/etc/passwd
            echo 'safety:x:1000:' >> $root/$target/etc/group
            echo 'safety:!:0:0:99999:7:::' >> $root/$target/etc/shadow
            mkdir -p $root/$target/home/safety
            rm -f $root/$target/etc/hostname
            echo $target > $root/$target/etc/hostname
            echo 127.0.0.1  $target >> $root/$target/etc/hosts
            cp -f --remove-destination /etc/resolv.conf $root/$target/etc/resolv.conf" &>/dev/null
    end
    if [ "$logcat" = debug ]
        logger 3 "Configuring $target"
        br_chroot $target /bin/sh -c '/bin/chown -R safety:safety /home/safety
            /bin/chmod -R 755 /home/safety & echo "safety    ALL=(ALL:ALL) ALL" >> /etc/sudoers
            echo "0d7882da60cc3838fabc4efc62908206" > /etc/machine-id
            (crontab -l 2>/dev/null; echo @reboot ip link set host0 name eth0) | crontab -'
    else
        br_chroot $target /bin/sh -c '/bin/chown -R safety:safety /home/safety
            /bin/chmod -R 755 /home/safety & echo "safety    ALL=(ALL:ALL) ALL" >> /etc/sudoers
            echo "0d7882da60cc3838fabc4efc62908206" > /etc/machine-id
            (crontab -l 2>/dev/null; echo @reboot ip link set host0 name eth0) | crontab -' &>/dev/null
    end
    return 0
end