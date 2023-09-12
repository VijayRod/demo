```
wget -P /tmp https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64
chmod +x /tmp/hey_linux_amd64
/tmp/hey_linux_amd64 -h

# Alternate commands
git clone https://github.com/rakyll/hey.git /tmp/hey
cd /tmp/hey
make
cd /bin
/tmp/hey/bin/hey_linux_amd64 -h
```

```
./hey_linux_amd64 -z 30s -q 100 -o csv http://AG_IP > /tmp/result_30s.csv # 50 threads (default) for 60 seconds at 100 requests/sec
cat /tmp/result_30s.csv # Check for errors
```

- https://github.com/rakyll/hey.git
