function level_exist
    set target $argv[1]
    set level_json (cat "$root/level_index.json")
    if echo "$level_json" | jq -er ".levels[] | select(.uuid==\"$target\")" &>/dev/null
        set target (echo "$level_json" | jq -r ".levels[] | select(.uuid==\"$target\").uuid")
        if test (echo "$level_json" | jq -r ".levels[] | select(.uuid==\"$target\").variant") = kvm_machine
            if test -e $root/$target
                return 0
            else
                return 1
            end
        else
            if test -d $root/$target
                return 0
            else
                return 1
            end
        end
    else
        if echo "$level_json" | jq -er ".levels[] | select(.alias==\"$target\")" &>/dev/null
            set target (echo "$level_json" | jq -r ".levels[] | select(.alias==\"$target\").uuid")
            if test (echo "$level_json" | jq -r ".levels[] | select(.uuid==\"$target\").variant") = kvm_machine
                if test -e $root/$target
                    return 0
                else
                    return 1
                end
            else
                if test -d $root/$target
                    return 0
                else
                    return 1
                end
            end
        else
            return 1
        end
    end
end
