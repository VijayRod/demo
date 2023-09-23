```
cd /tmp
git clone https://github.com/k-five/curly.git
sudo mv curly/curly.sh /usr/local/bin/curly
curly --command check
```

```
curly --ssl valid -d stackoverflow.com # Check certificate validity period
curly --ssl date -d stackoverflow.com # Check certificate expiration date
curly --ssl name -d stackoverflow.com # List supported names (domains) on the SSL certificate
curly --ssl cert -d stackoverflow.com # Check the SSL certificate
```

- https://github.com/shakibamoshiri/curly
