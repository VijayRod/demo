```
echo > /dev/tcp/google.com/80
echo "Test" > /dev/tcp/google.com/80

echo > /dev/tcp/google.com/81
^C-bash: connect: Network is unreachable
-bash: /dev/tcp/google.com/81: Network is unreachable
```

```
# Send the output to port 3333 and view the output with netcat
# Terminal 1
nc -l 3333
# Terminal 2
ls >/dev/tcp/localhost/3333
```

```
while true; echo -e '\n\n\n\n'$(date);  do sleep 1; (echo > /dev/tcp/google.com/443) >/dev/null 2>&1 && echo "up" || echo "down"; done >result.txt # cat result.txt | grep down # Credits: Ricardo
while true; echo -e '\n\n\n\n'$(date);  do sleep 1; (echo > /dev/tcp/8.8.8.8/443) >/dev/null 2>&1 && echo "up" || echo "down"; done # Credits: Ricardo
```

- https://tldp.org/LDP/abs/html/devref1.html#DEVTCP
- https://unix.stackexchange.com/questions/311095/are-dev-udp-tcp-standardized-or-available-everywhere
- https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Redirections: /dev/tcp
- https://andreafortuna.org/2021/03/06/some-useful-tips-about-dev-tcp/
