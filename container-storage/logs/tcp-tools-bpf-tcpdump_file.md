```
tcpdump port 443 -w /tmp/capture_file
cp /tmp/capture_file /tmp/capture_file.pcap # Renaming for .pcap reading
tcpdump -r /tmp/capture_file.pcap # Read the pcap file

# Alternative
tcpdump port 443 -w /tmp/capture_file.pcap
tcpdump port 443 -r /tmp/capture_file.pcap # Read the pcap file

ls /tmp/capture_file*
# rm /tmp/capture_file
```
