function api
    set path (status --current-filename)
    set dir (pwd)
    set logicpipe (mktemp)
    sed -n '/^function logicpipe/,/^end/p' $path | sed '1d; $d' | tee "$logicpipe" &>/dev/null
    chmod +x "$logicpipe"
    if test "$logcat" = debug
        logger 2 "Logicpipe loaded"
    end
    trap "logger 2 Main thread stopped && rm $logicpipe" INT
    set port $argv[2]
    set ip $argv[3]
    switch $argv[1]
        case ss
            set cert $argv[4]
            set key $argv[5]
            if test -e "$cert"; or test -e "$key";or test -r "$cert"; or test -r "$key"
                logger 5 "Cert or key file is not available or readable"
            else
                socat openssl-listen:$port,bind=$ip,cert=$cert,key=$key,verify=0,reuseaddr,fork,end-close EXEC:"fish $logicpipe $ip $port "$path" "$dir""
            end
        case s
            socat tcp-listen:$port,bind=$ip,reuseaddr,fork,end-close EXEC:"fish $logicpipe $ip $port "$path" "$dir""
        case '*'
            logger 5 "Option $argv[1] not found at backroom.host"
    end
end
