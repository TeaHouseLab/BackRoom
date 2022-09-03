function logicpipe
    while read request_raw
        set request_raw_process (echo $request_raw | tr '\r' ' ')
        set request "$request $request_raw_process"
        if test "$request_raw" = \r
            break
        end
    end
    set ip $argv[1]
    set port $argv[2]
    set path $argv[3]
    set dir $argv[4]
    set request_path (echo $request | tr ' ' '\n' | awk '/GET/{getline; print}')
    set 200 "HTTP/1.1 200 OK
Content-Type:*/*; charset=UTF-8"
    set 302 "HTTP/1.1 302 Found"
    set 403 "HTTP/1.1 403 Forbidden
Content-Type:*/*; charset=UTF-8"
    set 404 "HTTP/1.1 404 Not Found
Content-Type:*/*; charset=UTF-8"
    if echo $request_path | grep -qs "?"
        set request_path (echo $request | tr ' ' '\n' | awk '/GET/{getline; print}' | awk -F "?" '{print $1}')
        set request_argv (echo $request | tr ' ' '\n' | awk '/GET/{getline; print}' | awk -F "?" '{print $2}')
        set arg true
    end
    switch $request_path
        case '/manage/*'
            set level_1 (echo "$request_path" | sed 's/\/manage\///g')
            switch $level_1
                case 'level/*'
                    set level_2 (echo "$level_1" | sed 's/level\///g')
                    switch $level_2
                        case 'add/*'
                            set level_3 (echo "$level_2" | sed 's/add\///g')
                            switch $level_3
                                case 'rootfs*'
                                    set output ($path $dir info manage level add rootfs (echo "$request_argv" | string split '&'))
                                    echo -e "$200\r\n"
                                    echo "{\"created\": true, \"uuid\": \"$(echo $output | awk -F ' ' '{print $13}')\"}"
                                case 'kvm*'

                            end
                        case 'del*'
                            $path $dir info manage level del (echo "$request_argv" | string split '&') &>/dev/null
                        case 'info*'
                            echo -e "$200\r\n"
                            $path $dir info manage level info (echo "$request_argv" | string split '&')
                        case 'list/*'
                            set level_3 (echo "$level_2" | sed 's/list\///g')
                            switch $level_3
                                case 'available*'
                                    echo -e "$200\r\n"
                                    $path $dir info manage level list available (echo "$request_argv" | string split '&')
                                case installed
                                    echo -e "$200\r\n"
                                    $path $dir info manage level list installed
                            end
                    end
                case 'service/*'
                    set level_2 (echo "$level_1" | sed 's/service\///g')
                    switch $level_2
                        case 'del*'
                            $path $dir info manage service del (echo "$request_argv" | string split '&') &>/dev/null
                    end
                case 'power/*'
                    set level_2 (echo "$level_1" | sed 's/power\///g')
                    switch $level_2
                        case 'on*'
                            $path $dir info manage service power on (echo "$request_argv" | string split '&') &>/dev/null
                        case 'off*'
                            $path $dir info manage service power off (echo "$request_argv" | string split '&') &>/dev/null
                        case 'reboot*'
                            $path $dir info manage service power reboot (echo "$request_argv" | string split '&') &>/dev/null
                    end
            end
        case '*'
            echo -e "$404\r\n"
            echo 'Unknown at logicpipe'
    end
end
