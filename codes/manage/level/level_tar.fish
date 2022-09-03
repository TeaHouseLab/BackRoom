function level_tar
    set timestamp (date -u +"%Y-%m-%d-%H-%M-%S")
    switch $argv[1]
        case tar
            echo "[]" >"$root/brpack.info"
            set counter 1
            for level in $argv[2..-1]
                if level_exist $level
                    set level_info (jq -er ".[] | select(.uuid==\"$target\")" "$root/level_index.json")
                    jq ". + [$level_info]" "$root/brpack.info" | sponge "$root/brpack.info"
                    set level_list[$counter] "$target"
                    set counter (math "$counter+1")
                else
                    logger 5 "Level $level is not found under $root"
                    set level_onboard false
                end
            end
            if test "$level_onboard" = false
                rm "$root/brpack.info"
                logger 5 "You have levels aren't existed under this root"
                return 1
            else
                logger 0 "Start packing levels"
                if tar -I 'zstd -T0' -cf "$root/$timestamp.brpack" brpack.info $level_list
                    rm "$root/brpack.info" 
                    logger 2 "Level onboard, stored at $root/$timestamp.brpack"
                else
                    rm "$root/$timestamp.brpack" "$root/brpack.info"
                    logger 5 "Failed to package levels"
                end
            end
        case untar
            set random (random)
            mkdir "$root/"$random"untar"
            logger 0 "Start untar levels"
            if tar -I 'zstd -T0' -xf $argv[2] -C "$root/"$random"untar"
                set brpack_json (cat "$root/"$random"untar/brpack.info")
                for level in (echo "$brpack_json" | jq -er ".[] | .uuid")
                    set level_info (echo "$brpack_json" | jq -er ".[] | select(.uuid==\"$level\")")
                    mv "$root/"$random"untar/$level" "$root"
                    jq ". + [$level_info]" "$root/level_index.json" | sponge "$root/level_index.json"
                end
                rm -rf "$root/"$random"untar"
                logger 2 "Level merged into root $root"
            else
                rm -rf "$root/"$random"untar"
                logger 5 "Failed to untar $argv[2]"
            end
        case '*'
            logger 5 "Option $argv[1] not found at backroom.level.tar"
    end
end
