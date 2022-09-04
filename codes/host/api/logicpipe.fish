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
    set -x output
    set request_path (echo $request | tr ' ' '\n' | awk '/GET/{getline; print}')
    set 200 "HTTP/1.1 200 OK
Content-Type:*/*; charset=UTF-8"
    set 403 "HTTP/1.1 403 Forbidden
Content-Type:*/*; charset=UTF-8"
    set 404 "HTTP/1.1 404 Not Found
Content-Type:*/*; charset=UTF-8"
    set 500 "HTTP/1.1 500 Internal Server Error
Content-Type:*/*; charset=UTF-8"
    function status_return
        if test "$argv[1]" = 500
            echo -e "$500\r\n"
            echo "{\"action\": false, \"output\": \"$output\"}"
        else
            echo -e "$$argv[1]\r\n"
        end
    end
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
                                    if set output ($path $dir info manage level add rootfs (echo "$request_argv" | string split '&'))
                                        status_return 200
                                        echo "{\"succeeded\": true, \"uuid\": \"$(echo $output | awk -F ' ' '{print $(NF-2)}')\"}"
                                    else
                                        status_return 500
                                    end
                                case 'kvm*'
                                case '*'
                                    status_return 404
                                    echo 'Unknown action at backroom.manage.level.add'
                            end
                        case 'del*'
                            if set output ($path $dir info manage level del (echo "$request_argv" | string split '&'))
                                status_return 200
                                echo "{\"succeeded\": true}"
                            else
                                status_return 500
                            end
                        case 'info*'
                            if set output ($path $dir info manage level info (echo "$request_argv" | string split '&'))
                                status_return 200
                                echo "$output"
                            else
                                status_return 500
                            end
                        case 'list/*'
                            set level_3 (echo "$level_2" | sed 's/list\///g')
                            switch $level_3
                                case 'available*'
                                    if set output ($path $dir info manage level list available (echo "$request_argv" | string split '&'))
                                        status_return 200
                                        echo $output
                                    else
                                        status_return 500
                                    end
                                case installed
                                    if set output ($path $dir info manage level list installed)
                                        status_return 200
                                        echo $output
                                    else
                                        status_return 500
                                    end
                            end
                        case '*'
                            status_return 404
                            echo 'Unknown action at backroom.manage.level'
                    end
                case 'service/*'
                    set level_2 (echo "$level_1" | sed 's/service\///g')
                    switch $level_2
                        case 'del*'
                            if set output ($path $dir info manage service del (echo "$request_argv" | string split '&'))
                                status_return 200
                                echo "{\"succeeded\": true}"
                            else
                                status_return 500
                            end
                        case '*'
                            status_return 404
                            echo 'Unknown action at backroom.manage.service'
                    end
                case 'power/*'
                    set level_2 (echo "$level_1" | sed 's/power\///g')
                    switch $level_2
                        case 'on*'
                            if set output ($path $dir info manage service power on (echo "$request_argv" | string split '&'))
                                status_return 200
                                echo "{\"succeeded\": true}"
                            else
                                status_return 500
                            end
                        case 'off*'
                            if set output ($path $dir info manage service power off (echo "$request_argv" | string split '&'))
                                status_return 200
                                echo "{\"succeeded\": true}"
                            else
                                status_return 500
                            end
                        case 'reboot*'
                            if set output ($path $dir info manage service power reboot (echo "$request_argv" | string split '&'))
                                status_return 200
                                echo "{\"succeeded\": true}"
                            else
                                status_return 500
                            end
                        case '*'
                            status_return 404
                            echo 'Unknown action at backroom.manage.power'
                    end
                case '*'
                    status_return 404
                    echo 'Unknown action at backroom.manage'
            end
        case '*'
            status_return 404
            echo 'Unknown action at backroom.main'
    end
end
