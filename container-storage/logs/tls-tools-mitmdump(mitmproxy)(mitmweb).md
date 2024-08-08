```
# install
kubectl get no -owide
aks-nodepool1-22105430-vmss000000   Ready    agent   47h   v1.28.10   10.224.0.62   <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-22105430-vmss000001   Ready    agent   47h   v1.28.10   10.224.0.33   <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1

aks-nodepool1-22105430-vmss000001:/# apt install mitmproxy -y
aks-nodepool1-22105430-vmss000001:/# mitmdump
Proxy server listening at http://*:8080

aks-nodepool1-22105430-vmss000000:/# export http_proxy=http://10.224.0.33:8080
# echo $http_proxy # unset http_proxy
```

```
# good run
aks-nodepool1-22105430-vmss000000:/# curl http://mitm.it # <!doctype html>

# bad run
aks-nodepool1-22105430-vmss000000:/# curl http://mitm.it # If you can see this, traffic is not passing through mitmproxy

# bad run - the proxy (mitmdump) needs to be operational on a separate machine
aks-nodepool1-22105430-vmss000001:/# curl http://mitm.it # "The proxy shall not connect to itself"
```

```
# sample output
aks-nodepool1-22105430-vmss000000:/# curl http://mitm.it
aks-nodepool1-22105430-vmss000000:/# curl http://mitm.it -I

aks-nodepool1-22105430-vmss000001:/# mitmdump
Proxy server listening at http://*:8080
10.224.0.62:50240: clientconnect
10.224.0.62:50240: GET http://mitm.it/
                << 200 OK 16.72k
10.224.0.62:50240: clientdisconnect
10.224.0.62:57600: clientconnect
10.224.0.62:57600: HEAD http://mitm.it/
                << 200 OK 0b
10.224.0.62:57600: clientdisconnect
```

- https://docs.mitmproxy.org/stable/#mitmdump
- https://stackoverflow.com/questions/62483878/dump-packets-collected-with-mitmproxy: It does not matter if you use mitmproxy or mitmdump. Both programs support nearly the same functionality, except that mitmdump is a command-line tool that does not shows a GUI.
- https://www.golinuxcloud.com/set-up-proxy-http-proxy-environment-variable/
- tbd https://www.shellhacks.com/linux-proxy-server-settings-set-proxy-command-line/

```
# output to file
# aks-nodepool1-22105430-vmss000000:/# curl http://mitm.it -I
aks-nodepool1-22105430-vmss000001:/# mitmdump -w /tmp/outfile
Proxy server listening at http://*:8080
10.224.0.62:53490: clientconnect
10.224.0.62:53490: HEAD http://mitm.it/
                << 200 OK 0b
10.224.0.62:53490: clientdisconnect
^Croot@aks-nodepool1-22105430-vmss000001:/# cat /tmp/outfile
1683:7:version;2:10#4:mode;7:regular;8:response;256:6:reason;2:OK,11:status_code;3:200#13:timestamp_end;17:1723139002.022125^15:timestamp_start;18:1723139002.0221248^8:trailers;0:~7:content;0:,7:headers;74:44:12:content-type,24:text/html; charset=utf-8,]22:14:content-length,1:0,]]12:http_version;8:HTTP/1.1,}7:request;347:4:path;1:/,9:authority;0:,6:scheme;4:http,6:method;4:HEAD,4:port;2:80#4:host;7:mitm.it;13:timestamp_end;18:1723139001.8686557^15:timestamp_start;18:1723139001.8658886^8:trailers;0:~7:content;0:,7:headers;111:17:4:Host,7:mitm.it,]29:10:User-Agent,11:curl/7.81.0,]15:6:Accept,3:*/*,]34:16:Proxy-Connection,10:Keep-Alive,]]12:http_version;8:HTTP/1.1,}8:metadata;0:}6:marked;5:false!9:is_replay;0:~11:intercepted;5:false!4:type;4:http;11:server_conn;407:3:via;0:~4:via2;0:~11:cipher_list;0:~11:cipher_name;0:~11:alpn_offers;0:~16:certificate_list;0:]3:tls;0:~5:error;0:~5:state;1:0#13:timestamp_end;0:~19:timestamp_tls_setup;0:~19:timestamp_tcp_setup;0:~15:timestamp_start;0:~11:tls_version;0:~21:alpn_proto_negotiated;0:~3:sni;0:~15:tls_established;5:false!14:source_address;7:0:;1:0#]10:ip_address;0:~7:address;0:~2:id;36:074bc4e1-2c1a-4ee4-91b8-298844432318;}11:client_conn;431:11:cipher_list;0:~11:alpn_offers;0:~16:certificate_list;0:]3:tls;0:~5:error;0:~8:sockname;7:0:;1:0#]5:state;1:0#14:tls_extensions;0:~11:tls_version;0:~21:alpn_proto_negotiated;0:~11:cipher_name;0:~3:sni;0:~13:timestamp_end;0:~19:timestamp_tls_setup;0:~15:timestamp_start;18:1723139001.8625271^8:mitmcert;0:~15:tls_established;5:false!7:address;38:18:::ffff:10.224.0.62;5:53490#1:0#1:0#]2:id;36:0ed87712-b0e5-4f68-9cb3-09153442c1dc;}5:error;0:~2:id;36:0e70fe3e-3c15-4557-b231-a69fcdab6b5f;}
```

```
# bypass the proxy
curl --noproxy '*' http://mitm.it
If you can see this, traffic is not passing through mitmproxy.

curl --noproxy '*' http://mitm.it -I -v
*   Trying 18.239.196.111:80...
* Connected to mitm.it (18.239.196.111) port 80 (#0)
> HEAD / HTTP/1.1

curl http://mitm.it -I -v
* Uses proxy env variable http_proxy == 'http://10.224.0.33:8080'
*   Trying 10.224.0.33:8080...
* Connected to (nil) (10.224.0.33) port 8080 (#0)
> HEAD http://mitm.it/ HTTP/1.1
```

- https://stackoverflow.com/questions/13559377/curl-bypass-proxy-for-localhost

```
# capture filters

curl http://mitm.it -I
curl http://mitm.it
aks-nodepool1-22105430-vmss000001:/# mitmdump "~m GET"
Only processing flows that match "~m GET"
Proxy server listening at http://*:8080
10.224.0.62:56758: clientconnect
10.224.0.62:56758: clientdisconnect
10.224.0.62:48264: clientconnect
10.224.0.62:48264: GET http://mitm.it/
                << 200 OK 16.72k
10.224.0.62:48264: clientdisconnect

curl http://mitm.it -I
aks-nodepool1-22105430-vmss000001:/# mitmdump "~m HEAD"
Only processing flows that match "~m HEAD"
Proxy server listening at http://*:8080
10.224.0.62:60788: clientconnect
10.224.0.62:60788: HEAD http://mitm.it/
                << 200 OK 0b
10.224.0.62:60788: clientdisconnect
```

- https://quickref.me/mitmproxy.html#mitmproxy-filter
- https://docs.mitmproxy.org/stable/concepts-filters/

```
# capture filters scripts

https://docs.mitmproxy.org/stable/addons-examples/
tbd https://github.com/mitmproxy/mitmproxy/tree/main/examples
```

```
# read or replay a saved file without using a proxy

mitmdump --rfile /tmp/outfile -n # mitmproxy --rfile /tmp/outfile -n
10.224.0.62:53490: HEAD http://mitm.it/
                << 200 OK 0b
```

```
# analyze with wireshark

tbd
https://mitmproxy.org/, Download Windows Installer
SSLKEYLOGFILE="$PWD/.mitmproxy/sslkeylogfile.txt" mitmdump -w /tmp/outfile
kubectl cp nsenter-310ioi:/tmp/outfile /tmp/outfile
```

- https://github.com/muzuiget/mitmpcap
- https://docs.mitmproxy.org/stable/howto-wireshark-tls/
- https://www.wireshark.org/docs/dfref/t/tls.html
- tbd https://www.koyeb.com/blog/inspect-tls-encrypted-traffic-using-mitmproxy-and-wireshark

tbd
- https://www.petergirnus.com/blog/decrypting-https-traffic-with-mitmproxy-amp-wireshark
- https://a-xor-b.blogspot.com/2019/01/mitmproxy-decrypting-tls-traffic-in.html
- https://stackoverflow.com/questions/50207103/mitmproxy-make-output-human-readable-to-file
- https://commandmasters.com/commands/mitmdump-common/
