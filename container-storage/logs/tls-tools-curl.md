```
curl -ikv https://$fqdn
curl --trace /path/to/trace.log https://example.com
curl --trace-ascii /path/to/trace.log https://example.com # Does not print the binary data unlike trace
```
