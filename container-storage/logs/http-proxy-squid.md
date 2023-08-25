```
sudo apt update; sudo apt install -y squid

# sudo nano /etc/squid/squid.conf. Add the below lines at the beginning to allow all requests for this demo.
acl all src 0.0.0.0/0
http_access allow all

sudo systemctl restart squid
```

```
sudo systemctl status squid

netstat -tnlp | grep 3128

curl -I 127.0.0.1:3128
HTTP/1.1 400 Bad Request
Server: squid/3.5.27
Mime-Version: 1.0
Date: Fri, 25 Aug 2023 14:39:44 GMT
Content-Type: text/html;charset=utf-8
Content-Length: 3517
X-Squid-Error: ERR_INVALID_URL 0
```

- http://www.squid-cache.org/Doc/config/
- https://stackoverflow.com/questions/42901716/how-do-i-allow-access-to-all-requests-through-squid-proxy-server
