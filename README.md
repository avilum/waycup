# WayCup
These scripts let you expose your real server functionality only after sending a magic "Wake Up" packet to an open port.<br>
You can use WayCup as an <b>additional</b> layer of security against fingerprinting for your SSH/HTTP servers (and many more), or a minimal alternative to port knocking.<br><br>
Run a local example: reverse shell with magic handshake<br>
```bash
# apk add git
# apt install -y git netcat

git clone https://github.com/avilum/waycup.git && cd waycup/

nohup ./server.sh & # Or in another terminal

# To watch server logs:
# tail -f nohup.out

./client.sh
# Starts a reverse shell on the server, or change server_main.sh to do anything you want.

```
### Use Cases:
1. Hide services from security scanners (Shodan, Censys, nmap, zmap) and hackers (port scanning and fingerprint fails).
2. Keep your server a secret while it listens to www facing ports. It's like a black hole.
2. Expose a service's functionality on a port only to clients with a pre-shared secret, without modifying the application layer or managing users.
4. Copy/Paste where you don't want to configure a proxy like nginx. Also, it's easy to fingerprint nginx. This is a copy/paste solution with almost no dependencies.
5. Honeypots - Log all the transport to a file with tcpdump/alternative.

### Less secure (but nice) use cases:
1. Use as an API for remote calls on a machine (run a generic script)
2. When SSH is not (or can't be) installed - pure reverse bash shell.
3. Pentesting and Red Teams.

## How it works:
It wraps your appliction with a "black hole" that swallows automatic crawlers and bots, thus leaving your assets "anonymous" and making cyber attacks on your assets more complex.
<br>
1. The server(s) listen on any port for a magic packet via TCP/UDP. 
2. A magic "Wake Up" packet is sent from a client.
3. The "Wake Up" packet is received by the server.
3. The server runs a generic script, that exposes the service (SSH, HTTP, Anything) to the client on the same (or on a new) port.
4. If the server supports routing tables manipulation, the iptables can be modified and the client can keep communicating over the same port. see ./server.sh for more information.

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

Python: Send a magic packet that reveals an HTTP Server
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
import socket
MAGIC="secret"
SERVER_HOST="localhost"
SERVER_MAGIC_PORT=8080
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((SERVER_HOST, SERVER_MAGIC_PORT))
    s.sendall(MAGIC.encode())

# Query the API / Connect to the service on the same or different that just opened for you

import requests

# Modify server_main.sh to run an http server (uncomment a line)
requests.get('http://localhost:80') 
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

OpenSSL:
```bash
Not implimented yet - feel free to contribute!

# Generate random secret:
SECRET=$(openssl rand -base64 512) # Copy to server.sh and client.sh.


# Generate a random MAC address for the server:
sudo ifconfig [interface_name] ether $(openssl rand -hex 6 | sed 's%\(..\)%\1:%g; s%.$%%')
```

BoringSSL:
```bash
Not implimented yet - feel free to contribute!
```

HMAC Validation:
```bash
Not implimented yet - feel free to contribute!
```

# Server Dependencies:
* nc/netcat

# Compitability:
* Runs on any UNIX system that supports busybox syntax.
* You can copy and paste it in your servers, as-is, if you have <code>nc</code> installed.
* BSD netcat does not supports client IP extraction and iptables modification (yet), install GNU netcat for better compitability.
* Mac users - Remove "-w" argument in server.sh and add "-c" argument to client.sh

# Nc manual:
```bash
nc
nc [OPTIONS] HOST PORT - connect nc [OPTIONS] -l -p PORT [HOST] [PORT] - listen

Options:

        -e PROG         Run PROG after connect (must be last)
        -l              Listen mode, for inbound connects
        -n              Don't do DNS resolution
        -s ADDR         Local address
        -p PORT         Local port
        -u              UDP mode
        -v              Verbose
        -w SEC          Timeout for connects and final net reads
        -i SEC          Delay interval for lines sent
        -o FILE         Hex dump traffic
        -z              Zero-I/O mode (scanning)
```
