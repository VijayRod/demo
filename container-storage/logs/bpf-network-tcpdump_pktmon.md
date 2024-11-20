## pktmon

```
# admin: cmd

ipconfig /all
pktmon component list

sc qc pktmon
[SC] QueryServiceConfig SUCCESS
SERVICE_NAME: pktmon
        TYPE               : 1  KERNEL_DRIVER
        START_TYPE         : 3   DEMAND_START
        ERROR_CONTROL      : 1   NORMAL
        BINARY_PATH_NAME   : system32\drivers\PktMon.sys
        LOAD_ORDER_GROUP   :
        TAG                : 0
        DISPLAY_NAME       : Packet Monitor Driver
        DEPENDENCIES       :
        SERVICE_START_NAME :
```

```
# capture
# admin: cmd
pktmon filter remove
pktmon filter add myprotocol -t ICMP
pktmon filter add myIPFilter -i 127.0.0.1
pktmon start -c -f .\pktmon.etl
# pktmon counters

ping 8.8.8.8
ping 127.0.0.1

pktmon stop
pktmon etl2pcap pktmon.etl # pktmon.pcapng (wireshark)

# wireshark: icmp
1	2024-11-20 22:13:44.429602	1.2.3.4	8.8.8.8	ICMP	74	0x97e5 (38885)			
2	2024-11-20 22:13:44.429619	1.2.3.4	8.8.8.8	ICMP	74	0x97e5 (38885)			
3	2024-11-20 22:13:44.429624	1.2.3.4	8.8.8.8	ICMP	74	0x97e5 (38885)			
4	2024-11-20 22:13:44.429626	1.2.3.4	8.8.8.8	ICMP	74	0x97e5 (38885)			
```

- https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/pktmon
- https://learn.microsoft.com/en-us/windows-server/networking/technologies/pktmon/pktmon: The tool is especially helpful in virtualization scenarios, like container networking and SDN, because it provides visibility within the networking stack
