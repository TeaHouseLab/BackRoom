function br_chroot
    set target $argv[1]
    if level_exist $target
    else
        logger 5 "Level $target is not found under $root"
        exit 1
    end
    mount_utils mount $target
    chroot $root/$target $argv[2..-1]
    mount_utils umount $target
end
