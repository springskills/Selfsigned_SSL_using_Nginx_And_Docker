The first server block listens on port 80 and redirects all HTTP traffic to HTTPS using a 301 redirect. The other server block listens on port 443 with SSL enabled, and proxies incoming requests to a backend server running on http://1IP:PORT.

```shell
server {
  listen 80 default_server;	    
  server_name 192.168.100.111;
  return 301 https://$host$request_uri;
}
```
This block specifies that the server should listen on `port 80` as the default server and redirect all incoming traffic to https using a `301 redirect`.

`$host` is a variable that gets replaced by the name of the host making the request, and `$request_uri` is a variable that gets replaced by the URI being requested.
```shell
server {
listen 443 ssl;
server_name IP;

    ssl_certificate /etc/nginx/certs/certificate.crt;
    ssl_certificate_key /etc/nginx/certs/private.key;

    location / {
        proxy_pass http://IP:PORT;
        #proxy_set_header Host $host;
        #proxy_set_header X-Real-IP IP;
        #proxy_set_header X-Forwarded-Proto https;
        #proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #proxy_redirect off;
    }
}
```

This block specifies that the server should listen on port `443 with SSL`
enabled, and forwards all incoming traffic to the specified backend server
http://IP:PORT.

The `location /` block tells Nginx to pass all requests made to the root path of the server (i.e., /) to the specified backend server.

Additionally, there are commented out lines that show how to set
various HTTP headers for the proxied request.

For example, `proxy_set_header Host $host;` sets the Host header of the HTTP request to
the `$host` value.

Similarly, `proxy_set_header X-Real-IP IP;`
sets the X-Real-IP header of the HTTP request to the IP address 
`192.168.100.111`. 

These headers can be useful for passing 
additional information to the backend server or modifying the request 
before it's forwarded. However, they have been commented out in this
configuration file.
