# WayCup - A tool agains fingerprinting.<br>
WayCup scripts let you expose your real server functionality only after sending a magic "Wake Up" packet to an open port.<br>
You can use WayCup as an additional layer of security against fingerprinting for you SSH/HTTP servers (and many more).

## Use Cases:
1. Hide services behind open ports from security scanners (Shodan, Censys...)
2. Expose a service's fingerprint only to clients with pre-shared secret, without modifying the application layer or managing users.
3. Use as an API for remote calls on a machine (run a generic script)
4. When SSH is not (or can't be) installed - pure remote bash shell.
5. Leaving backdoors that start on demand (reverse shells)

## Concept:
1. The server(s) listen on any port for a magic packet via TCP/UDP. 
2. A magic "Wake Up" packet is sent from a client.
3. The "Wake Up" packet is received by the server.
3. The server runs a generic script, that exposes the service (SSH, HTTP...) to the client on the same (or on a new) port.

# Examples

## Running a server 
```bash
$ ./server.sh
Listening for magic packets on localhost:8080
Connection from 127.0.0.1:60427
Successful connection
Running the main startup script: ./server_main.sh
...
```

## Connecting clients
nc/netcat/socat/ncat magic packets:
```bash
MAGIC_LISTENER_HOST="localhost"
SERVER_MAGIC_PORT=8080

# Fails, until we send a magic packet.
ssh $MAGIC_LISTENER_HOST -p $SERVER_MAGIC_PORT 
connection refused.

# Sending a magic packet
MAGIC="secret"
echo $MAGIC | nc -c -vvv $MAGIC_LISTENER_HOST $MAGIC_LISTENER_PORT && echo "Success"

# Works now
ssh $MAGIC_LISTENER_HOST -p $SERVER_MAGIC_PORT 

# Do whatever you want here, based on the server implementation.
# See server_main.sh and client.sh for more documentation.
```

Python: Send a magic packet that starts an HTTP Server
```text
In [1]: import requests
In [2]: requests.get('http://localhost:80')
ConnectionError

In [3]: import socket;
   ...: MAGIC="change this magic string"
   ...: SERVER_HOST="localhost"
   ...: SERVER_MAGIC_PORT=8080
   ...: with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
   ...:     s.connect((SERVER_HOST, SERVER_MAGIC_PORT))
   ...:     s.sendall(MAGIC.encode())

In [4]: requests.get('http://localhost:80')
Out[4]: <Response [200]>
```
Copy and paste:
```python
MAGIC="secret"
SERVER_HOST="localhost"
SERVER_MAGIC_PORT=8080
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((SERVER_HOST, SERVER_MAGIC_PORT))
    s.sendall(MAGIC.encode())

# Query the API / Connect to the service on the same or different that's just opened for you
import requests
requests.get('http://localhost:80') # Change server.main.sh to run python3 http server on / when a client connects
```

Remote reverse-shell:
```bash
$ ./client.sh
Sending magic packet to localhost:8080
localhost [127.0.0.1] 8080 (http-alt) open
Total received bytes: 0
Total sent bytes: 25
Success
Starting reverse shell...
Connection from 127.0.0.1:60428
whoami
####
sudo su
whoami
root
```

# Adding security
You should add an extra layer of security if you want to prevent reply attacks. That can be done by adding a TLS layer to your server with OpenSSL/Boring SSL

SSL:
```bash
# install openssl
```

HMAC Validation:
```bash
```

# Server Dependencies:
* nc/netcat

# Compitability:
* Runs on any UNIX system that supports busybox syntax.
* You can copy and paste it in your servers, as-is, if you have <code>nc</code> installed.