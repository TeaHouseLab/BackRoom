function level_index_db
    if test -e $root
        if test -d $root
            if test -w $root; and test -r $root
                if test -e "$root/level_index.json"
                    if test "$logcat" = debug
                        logger 3 "Index is available"
                    end
                else
                    if echo '{"remote": "", "levels": []}' >"$root/level_index.json"
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
end
