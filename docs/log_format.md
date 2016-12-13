## log_format
### conf
```conf
    log_format  main  '$remote_addr - $remote_user [$time_local] '
                      '$status $request_time $sent_http_x_f_cache "$request" '
                      '$body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
```
### log
```conf
[05/Sep/2016:13:09:26 +0000] "tech.air-foron.com" - 123.456.789.012 - - -
200 0.000 HIT - 4095 "GET / HTTP/1.1"
"-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:50.0) Gecko/20100101 Firefox/50.0" "-"
```

## LTSV
### conf
```conf
log_format main "time:$time_local\t"
                "host:$host\t"
                "hostname:$hostname\t"
                "remote_addr:$remote_addr\t"
# status,method
                "status:$status\t"
                "method:$request_method\t"
                "scheme:$scheme\t"
                "path:$uri\t"
                "query:$args\t"
# Request
                "req_bytes:$request_length\t"
                "req_time:$request_time\t"
                "res_bytes:$bytes_sent\t"
                "res_body_bytes:$body_bytes_sent\t"
                "res_cache_control:$sent_http_cache_control\t"
                "res_content_type:$sent_http_content_type\t"
# upstream
                "upstream_addr:$upstream_addr\t"
                "upstream_taken_time:$upstream_response_time\t"
                "upstream_cache_status:$upstream_cache_status\t"
# tracker
                "x_forwarded_for:$http_x_forwarded_for\t"
                "x_forwarded_for_proto:$http_x_forwarded_for_proto\t"
                "referer:$http_referer\t"
                "accept_language:$http_accept_language\t"
                "user_agent:$http_user_agent\t"
# TLS cipher
                "ssl_cipher:$ssl_cipher\t"
                "ssl_protocol:$ssl_protocol\t"
                "ssl_server_name:$ssl_server_name\t"
                "http2:$http2\t";


log_format warn "time:$time_local\t"
                "host:$host\t"
                "hostname:$hostname\t"
                "remote_addr:$remote_addr\t"
# status,method
                "status:$status\t"
                "method:$request_method\t"
                "scheme:$scheme\t"
                "path:$uri\t"
                "query:$args\t"
# Request
                "req_bytes:$request_length\t"
                "req_time:$request_time\t"
                "res_bytes:$bytes_sent\t"
                "res_body_bytes:$body_bytes_sent\t"
                "res_cache_control:$sent_http_cache_control\t"
                "res_content_type:$sent_http_content_type\t"
# upstream
                "upstream_addr:$upstream_addr\t"
                "upstream_taken_time:$upstream_response_time\t"
                "upstream_cache_status:$upstream_cache_status\t"
# tracker
                "x_forwarded_for:$http_x_forwarded_for\t"
                "x_forwarded_for_proto:$http_x_forwarded_for_proto\t"
                "referer:$http_referer\t"
                "accept_language:$http_accept_language\t"
                "user_agent:$http_user_agent\t"
# TLS cipher
                "ssl_cipher:$ssl_cipher\t"
                "ssl_protocol:$ssl_protocol\t"
                "ssl_server_name:$ssl_server_name\t"
                "http2:$http2\t"
# Request Body
                "req_body:$request_body\t";
```


```conf
    log_format main "time:$time_local"
                    "\tvhost:$host"
                    "\thost:$remote_addr"
                    "\tstatus:$status"
                    "\treqtime:$request_time"
                    "\tsize:$body_bytes_sent"
                    "\tfcache:$sent_http_x_f_cache"
                    "\treq:$request"
                    "\treferer:$http_referer"
                    "\tua:$http_user_agent"
                    "\tforwardedfor:$http_x_forwarded_for";

```
### log
```conf
        time:05/Sep/2016:13:50:10 +0000
        vhost:tech.air-foron.com
        host:123.456.789.012
        status:200
        reqtime:0.000
        size:4095
        fcache:HIT
        req:GET / HTTP/1.1
        referer:http://tech.air-foron.com/2016/09/02/hello-world/
        ua:Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:50.0) Gecko/20100101 Firefox/50.0
        forwardedfor:-
```


```conf
log_format main "time:time_local\t"
                ""
;
```
