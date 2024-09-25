## nc.telnet

```
nc -v www.microsoft.com 80
Connection to www.microsoft.com 80 port [tcp/http] succeeded!
```

## nc.listenmode
```
# Send the output to port 3333 and view the output with netcat
# Terminal 1
nc -l 3333
# Terminal 2
ls >/dev/tcp/localhost/3333
```
