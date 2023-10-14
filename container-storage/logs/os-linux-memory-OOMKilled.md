```
tail /dev/zero
Killed

bash -c "for b in {0..99999999}; do a=$b$a; done"
Killed

# stress-ng works in pods/containers too
```

- https://askubuntu.com/questions/1188024/how-to-test-oom-killer-from-command-line
