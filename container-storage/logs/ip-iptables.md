## iptables

```
iptables-save > /tmp/iptables
cat /tmp/iptables
```

- https://wiki.centos.org/HowTos/Network/IPTables
- https://www.man7.org/linux/man-pages/man8/iptables.8.html
- tbd https://www.baeldung.com/linux/iptables-intro

## iptables.chain

```
iptables -L | grep Chain
iptables -L INPUT # --line-numbers
iptables -nvL INPUT
iptables -nvL INPUT -t filter
iptables -t filter -nvL # To view all iptable chains
```

- https://thelinuxcode.com/iptables-tutorial/
- tbd https://stackoverflow.com/questions/14955973/iptables-what-is-a-chain
- https://unix.stackexchange.com/questions/506729/what-is-a-chain-in-iptables
- https://www.baeldung.com/linux/iptables-chains-tables-traversal
- https://unix.stackexchange.com/questions/189905/how-iptables-tables-and-chains-are-traversed
- https://stuffphilwrites.com/2014/09/iptables-processing-flowchart/
- https://upload.wikimedia.org/wikipedia/commons/3/37/Netfilter-packet-flow.svg
- https://rlworkman.net/howtos/iptables/chunkyhtml/c962.html
- http://linux-ip.net/pages/diagrams.html#netfilter-kernel-packet-traversal
- https://www.digitalocean.com/community/tutorials/a-deep-dive-into-iptables-and-netfilter-architecture
- tbd https://cloudzy.com/blog/iptables-show-rules/
- https://thelinuxcode.com/iptables-tutorial/: https://thelinuxcode.com/iptables-tutorial/

## iptables.tables

```
iptables -vL -t filter
iptables -vL -t nat
iptables -vL -t mangle
iptables -vL -t raw
iptables -vL -t security
```

- https://unix.stackexchange.com/questions/205867/viewing-all-iptables-rules: iptables controls five different tables: filter, nat, mangle, raw and security. ...
- https://thelinuxcode.com/iptables-tutorial/: These built-in chains belong to various  iptables tables...
