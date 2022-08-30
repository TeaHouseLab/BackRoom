set -x prefix "[BackRoom]"
set -x codename Joshua
set -x ver 1
set -x target
set -x root $argv[1]
set -x logcat $argv[2]
checkdependence jq curl sponge nano
if test -e $root
    if test -d $root
        if test -w $root; and test -r $root
            if test -e "$root/level_index.json"
                if test "$logcat" = debug
                    logger 3 "Index is available"
                end
            else
                if echo "[]" >"$root/level_index.json"
                    if test "$logcat" = debug
                        logger 3 "Index is available"
                    end
                else
                    logger 5 "Can not create index file in $root"
                    exit 1
                end
            end
        else
            logger 5 "root => $root is not Readable/Writable"
            exit 1
        end
    else
        logger 5 "root => $root is not a diretory file"
        exit 1
    end
else
    logger 5 "root => $root is not found"
    exit 1
end
switch $argv[3]
    case enter
        switch $argv[4]
            case nspawn
                br_nspawn $argv[5..-1]
            case chroot
                br_chroot $argv[5..-1]
        end
    case manage
        switch $argv[4]
            case service
                service $argv[5..-1]
            case level
                level $argv[5..-1]
        end
    case host
        api $argv[4..-1]
    case v version
        logger 1 "$codename@build$version"
    case h help '*'
        help_echo
end
