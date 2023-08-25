```
# To display verbose output, establish an insecure connection, and use a proxy connection without verifying the proxy
curl -vk --proxy-insecure https://mcr.microsoft.com/v2/
*   Trying 204.79.197.219...
* TCP_NODELAY set
* Connected to mcr.microsoft.com (204.79.197.219) port 443 (#0)

# To exclude proxy usage for all hosts
curl --noproxy '*' https://mcr.microsoft.com/v2/ -I
HTTP/2 200

# To exclude the use of a proxy for 'mcr.microsoft.com'
curl --noproxy 'mcr.microsoft.com' https://mcr.microsoft.com/v2/ -I
HTTP/2 200

# To use a localhost proxy
curl --proxy localhost:3128 https://mcr.microsoft.com/v2/ -I
HTTP/1.1 200 Connection established
HTTP/2 200
```
