function level_spawn
    set target $argv[1]
    if test "$logcat" = debug
        logger 3 "Spawning $target"
        sh -c "echo 'safety:x:1000:1000:safety,,,:/home/safety:/bin/sh' >> $root/$target/etc/passwd
            echo 'safety:x:1000:' >> $root/$target/etc/group
            echo 'safety:!:0:0:99999:7:::' >> $root/$target/etc/shadow
            mkdir -p $root/$target/home/safety
            rm -f $root/$target/etc/hostname
            echo $containername > $root/$target/etc/hostname
            echo 127.0.0.1  $containername >> $root/$target/etc/hosts
            cp -f --remove-destination /etc/resolv.conf $root/$target/etc/resolv.conf"
    else
        sh -c "echo 'safety:x:1000:1000:safety,,,:/home/safety:/bin/sh' >> $root/$target/etc/passwd
            echo 'safety:x:1000:' >> $root/$target/etc/group
            echo 'safety:!:0:0:99999:7:::' >> $root/$target/etc/shadow
            mkdir -p $root/$target/home/safety
            rm -f $root/$target/etc/hostname
            echo $containername > $root/$target/etc/hostname
            echo 127.0.0.1  $containername >> $root/$target/etc/hosts
            cp -f --remove-destination /etc/resolv.conf $root/$target/etc/resolv.conf" &>/dev/null
    end
    
end