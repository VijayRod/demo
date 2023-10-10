```
cd /tmp/jmeter; jmeter -n -t repro.jmx -f -l results.log -Jbackend_protocol=https -Jip_address=$ip
cat /tmp/jmeter/results.log | grep -v OK
# while true; do date; echo NOK - $(cat /tmp/jmeter/results.log | grep -v OK | wc -l); sleep 5; done
```
