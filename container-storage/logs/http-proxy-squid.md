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
```

- http://www.squid-cache.org/Doc/config/
- https://stackoverflow.com/questions/42901716/how-do-i-allow-access-to-all-requests-through-squid-proxy-server
