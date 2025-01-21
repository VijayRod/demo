## http

- https://www.w3.org/Protocols/rfc2616/rfc2616.html
- https://developer.mozilla.org/en-US/docs/Web/HTTP
- https://www.w3schools.com/whatis/whatis_http.asp
- https://http.dev/3

## http.error.contextcancelled

- https://www.willem.dev/articles/context-cancellation-explained/
- https://www.reddit.com/r/golang/comments/s7o5ay/investigating_context_canceled_http_errors/: client disconnects
- https://www.slingacademy.com/article/context-in-go-managing-timeouts-and-cancellations/#context-example-with-cancellation: cancel a pending operation

## http.logs

```
# working and non-working scenarios
nc -v www.microsoft.com 80 # or telnet google.com 80
curl -v google.com
F12 browser trace
```

## http.logs.har

- To enable HAR trace, follow the instructions here: [Capture a browser trace for troubleshooting - Azure portal | Microsoft Learn](https://learn.microsoft.com/en-us/azure/azure-portal/capture-browser-trace). Then, reproduce the issue and stop tracing.

## http.logs.sessionid

- To get the session ID, just hit CTRL+ALT+D on the Azure Portal.
- https://learn.microsoft.com/en-us/answers/questions/383171/how-to-get-unique-session-id-from-azure-b2c-sign-i
- https://wmatthyssen.com/2019/12/19/azure-tip-use-ctrlaltd-to-check-azure-portal-load-times/
