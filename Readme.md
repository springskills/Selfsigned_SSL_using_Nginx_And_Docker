## Deploying an Nginx Server Using Docker Compose


This guide is intended for developers and system administrators who want to secure their web applications with HTTPS without purchasing an SSL certificate from a trusted Certificate Authority (CA). The guide covers all the necessary steps, including installing Docker and Nginx, creating a self-signed SSL certificate, configuring Nginx to use the certificate, and testing the configuration. The instructions are accompanied by code snippets to make it easier for the users to follow along. Overall, this page serves as a useful resource for anyone looking to secure their web applications with HTTPS using self-signed certificates.


We will be creating a `docker-compose.yml` file in which we will define the configuration of our Nginx container.

### Prerequisites
- Docker and Docker Compose installed on your system.
- Familiarity with basic Docker concepts such as containers, images, and volumes.

## Create a docker-compose.yml file
Create a new file named `docker-compose.yml` in your project directory. This file will define the configuration of our Nginx container.

Copy the following code into the `docker-compose.yml` file:

```yml
version: "3"

services:
  nginx:
    image: nginx:stable
    container_name: 'nginx'
    restart: always
    #    ports:
    #      - 80:80
    #      - 443:443
    volumes:
      - ./nginx/sites-enabled/default.conf:/etc/nginx/conf.d/ssl.conf
      - ./nginx/certs/:/etc/nginx/certs
    network_mode: "host"

  #Varnish cache *******************
  varnish:
    image: varnish:stable
    container_name: varnish
    volumes:
      - "./varnish/default.vcl:/etc/varnish/default.vcl"
    #    ports:
    #      - "9090:80"
    tmpfs:
      - /var/lib/varnish:exec
    environment:
      - VARNISH_SIZE=80G
    network_mode: "host"
```

This code defines a single service called `nginx`. The `image` property specifies the Docker image that should be used, in this case `nginx:stable`.

The `container_name` property sets the name of the container to be created. In our case, we've set it to `nginx`.

The `restart` property indicates that the container should automatically restart if it exits for any reason.

The `volumes` property maps directories on the host machine to directories inside the container. In our case, we are mapping two directories: `./nginx/sites-enabled/default.conf` and `./nginx/certs/`.

The `network_mode` property sets the network mode for the container. In our case, we're setting it to `host`.


### varnish part
The "image" property specifies which Docker image to use for Varnish. In this case, we're using the "varnish:stable" image.

The "container_name" property sets the name of your Varnish container.

The "volumes" property maps your local "default.vcl" file to the "/etc/varnish/default.vcl" location inside the container.

The "tmpfs" property sets up a temporary file system at "/var/lib/varnish" that is used for caching.

The "environment" property sets the size of your cache to 80GB.

Finally, the "network_mode" property sets the networking mode to "host" so that your container can communicate with the host machine.
### More info
For more information about nginx read this: [Nginx config](./nginx/sites-enabled/Readme.md)

To produce certification files using openssl read this: [Certifications](./nginx/certs/Readme.md)




## Essential Security Measures to Secure Your Nginx and SSL Configurations

**1. Strong Passwords**\
  Use strong passwords for all user accounts, including the root account. A strong password should be at least 8 characters long and contain a combination of uppercase and lowercase letters, numbers, and symbols.

**2.    Firewall Rules**\
    Configure firewall rules to block all incoming traffic by default and only allow traffic that is necessary for your applications to function properly. You can use iptables or UFW (Uncomplicated Firewall) to set up firewall rules.

**3.    Configure SSL**\
    Make sure to use SSL (Secure Sockets Layer) to encrypt data transmitted between the client and server. You can use Let’s Encrypt, a free, automated, and open Certificate Authority, to obtain SSL certificates for your domain.

**4.    Disable Unnecessary Modules**\
    By disabling unnecessary modules in your Nginx configuration, you reduce the attack surface of your server. Check your Nginx installation for any unnecessary modules and disable them.

**5.  Regularly Update Nginx and SSL Configuration**\
    Keep your Nginx and SSL configurations up-to-date with the latest security patches and updates. This will help prevent potential vulnerabilities from being exploited.

**6.  Use Secure Protocols**\
    Use TLS (Transport Layer Security) 1.2 or higher instead of SSLv2 or SSLv3 which are known to have serious security vulnerabilities.

**7.  Enable HSTS**\
    HTTP Strict Transport Security (HSTS) instructs web browsers to use HTTPS instead of HTTP, even if the user types "http" in the browser address bar. This helps protect against man-in-the-middle attacks and other security threats.

**8.  Implement Rate Limiting**\
    Implement rate limiting to prevent brute-force attacks and DDoS attacks. This limits the number of requests a user or IP address can make within a certain time period.
    

## what is HSTS
**HTTP Strict Transport Security (HSTS)** is a security feature that allows a website to instruct web browsers to only communicate with the site over secure HTTPS connections, instead of allowing HTTP connections.

When a website uses HSTS, it sends a special response header to the client indicating that all future requests to the site should be made using HTTPS for a defined period of time. This can help protect users from various types of attacks such as man-in-the-middle (MITM) attacks, which can intercept and modify traffic between a user's browser and a website.

Enabling HSTS helps to ensure that a website is accessed securely, even if a user forgets to include "https://" in the URL or manually enters "http://" instead. It also prevents downgrade attacks where an attacker tries to force a client to switch from HTTPS to HTTP, potentially exposing sensitive information.

Overall, HSTS is a useful security mechanism that can help prevent various forms of attacks against web applications and improve the overall security posture of a website.


### Enable HSTS in nginx
Enabling HTTP Strict Transport Security (HSTS) in nginx is a relatively straightforward process that involves adding a few lines of configuration to your nginx server block. Here are the steps:

1.  Open your nginx configuration file. On Ubuntu and Debian systems, this is typically located at `/etc/nginx/nginx.conf`.

2.  Locate the `server` block for the domain you want to enable HSTS for.

3.  Add the following lines inside the `server` block:
```
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

This line of code sets the HSTS header to be sent to the client, with a max-age value of one year (31536000 seconds). The `includeSubDomains` parameter tells the browser to also apply HSTS to any subdomains of your site.

4.  Save the configuration file and reload nginx using the command:

```sh
sudo service nginx reload
```

That's it! Your site should now be using HSTS to enforce HTTPS connections.

### Example
Let's say you have a domain called `example.com` and your nginx configuration file is located at `/etc/nginx/nginx.conf`. You want to enable HSTS for this domain with a max-age value of one year.

1.  Open the configuration file in your preferred text editor:

```
sudo nano /etc/nginx/nginx.conf
```

2.  Locate the `server` block for `example.com`. It should look something like this:

```
server {
    listen 80;
    server_name example.com;
    ...
}
```

3.  Add the following line inside the `server` block, just below the `server_name` directive:

```
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

Your `server` block should now look like this:

```sh
server {
    listen 80;
    server_name example.com;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    ...
}
```

4.  Save the configuration file and reload nginx using the command:

```
sudo service nginx reload
```

That's it! Your site at `example.com` should now be using HSTS to enforce HTTPS connections, with a max-age value of one year.
