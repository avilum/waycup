#!/bin/sh

MAGIC="change this magic string"
BIND_HOST="localhost"
BIND_PORT=8080
STARTUP_SCRIPT="./server_main.sh"

while true; do
    echo "Listening for magic packets on $BIND_HOST:$BIND_PORT"
    INPUT=$( nc -vvv -l $BIND_HOST -p $BIND_PORT)
    if [[ "$INPUT" == $MAGIC ]]; then
        echo "Successful connection";
        echo "Running the main startup script: $STARTUP_SCRIPT"
        chmod +x $STARTUP_SCRIPT
        $STARTUP_SCRIPT &

        # You may want to comment it to allow multiple or single clients/loops.
        break
    else 
        echo "Failed connection";
    fi;
done
exit 0