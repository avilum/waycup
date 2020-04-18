#!/bin/sh

MAGIC="change this magic string"
MAGIC_HOST="localhost"
MAGIC_PORT=8080
REAL_SERVICE_PORT=8081 # Your real service listening port on localhost
STARTUP_SCRIPT="./server_main.sh"

# NOTICE:
# If your server supports iptables (or an Implemented alternative in server.sh),
# After the magic packet is sent,
# The client and server can keep communicatin over the same port
#   (by running the service on a localhost port and playing with the routing).

# OTHERWISE: You have 2 options
#   1. Break the loop (exit the nc listener) and start the service on the same port
#   2. Start the service on a new port that listens on localhost,
#       and route the ip of the client to that port seamlessly.

while true; do
    echo "Listening for magic packets on $MAGIC_HOST:$MAGIC_PORT"
    INPUT=$( nc -vvv -l -s $MAGIC_HOST -p $MAGIC_PORT -w 1 )
    if [[ $INPUT == $MAGIC ]]; then
        echo "Successful connection from $CLIENT_IP";

        # Calling the startup script and passing the client's IP and the port to serve on as arguments.
        chmod +x $STARTUP_SCRIPT
        echo "Running the main startup script: $STARTUP_SCRIPT $CLIENT_IP $REAL_SERVICE_PORT &"
        
        # For GNU netcat, you can fetch the client IP from the netcat log and authorize it via iptables.
        # TODO: Try to fetch it automatically from nc verbose log with sed/awk
        CLIENT_IP=$MAGIC_HOST
        $STARTUP_SCRIPT $CLIENT_IP $REAL_SERVICE_PORT 2>&1 &

        # If the server has any iptables or more modern alternative installed,
        # whitelisting it and redirecting the transport to the new port that listens on localhost.
        
        # TODO: Test on different unix dockers
        if type iptables 2>/dev/null; then
            echo "iptables found, redirecting the traffic for IP $CLIENT_IP from port $MAGIC_PORT -> $ALLOW_TO_PORT"
            # iptables -t nat -A PREROUTING -s $CLIENT_IP --dport $MAGIC_PORT -j DNAT --to 127.0.0.1:$REAL_SERVICE_PORT
            # iptables -t nat -A POSTROUTING -d 127.0.0.1 --dport $MAGIC_PORT -j MASQUERADE
        
        # TODO: Test on different unix dockers
        elif type ufw 2>/dev/null; then
            echo "ufw found"
            # TODO: Implement
        
        # TODO: Test on different unix dockers
        elif type nftables 2>/dev/null; then
            echo "nftables found"
            # iptables syntax should be compitable on debian 10+
            # TODO: Implement
        fi

        # You may want to comment it to allow multiple or single clients/loops.
        # break

    else 
        echo "Failed connection";
    fi;
done
