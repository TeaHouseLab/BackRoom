function level_seed
    set target $argv[1]
    set meta (curl -sL $remote/streams/v1/images.json | jq -r '.products')
    set latest (echo $meta | jq -r ".[\"$target\"].versions|keys|.[]" | tail -n1)
    set path (echo $meta | jq -r ".[\"$target\"].versions|.[\"$latest\"].items |.[\"root.tar.xz\"].path")
    if echo "$path" | grep -qs null
        logger 5 "Target does not exist in remote repo"
    else
        set sha256 (echo $meta | jq -r ".[\"$target\"].versions|.[\"$latest\"].items |.[\"root.tar.xz\"].sha256")
    end
    if test "$logcat" = "debug"
        logger 3 "Testing if package folder exist"
    end
    if test -d $root/.package
        if test "$logcat" = "debug"
            logger 3 "Package folder is existed"
        end
    else
        logger 4 "Package folder is not existed, trying to create it"
        if mkdir -p $root/.package
        else
            logger 5 "Can not create the package cache folder"
            exit 128
        end
    end
    if sudo -E curl --progress-bar -L -o $root/.package/$target.level $remote/$path
        if test "$(sha256sum $root/.package/$target.level | awk -F ' ' '{print $1}')"
            logger 2 "Level package $target checked"
        else
            logger 4 "Level package $target check sha256 failed"
            set check "failed"
        end
    end
end
