function mount_utils
    set target $argv[2]
    function mount_rw
        for mount_target in $argv
            if test "$logcat" = debug
                logger 3 "Mounting $mount_target to $root/$target$mount_target"
            end
            if grep -qs "$root/$target$mount_target" /proc/mounts
            else
                mount -o bind,rw "$mount_target" "$root/$target$mount_target"
            end
        end
    end
    function umount_rw
        for umount_target in $argv
            if test "$logcat" = debug
                logger 3 "Unmounting $umount_target $root/$target$umount_target"
            end
            if grep -qs "$root/$target$umount_target" /proc/mounts
                umount -l "$root/$target$umount_target"
            end
            if grep -qs /dev/pts /proc/mounts
            else
                mount devpts /dev/pts -t devpts
            end
        end
    end
    switch $argv[1]
        case mount
            mount_rw /dev /dev/pts /proc /sys
        case umount
            umount_rw /dev /dev/pts /proc /sys
        case '*'
            logger 5 "Option $argv[1] not found at backroom.chroot.mount_utils"
            return 1
    end
end
