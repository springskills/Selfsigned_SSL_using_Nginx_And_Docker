## Deploying an Nginx Server Using Docker Compose

In this tutorial, we will be using Docker Compose to deploy an Nginx server. We will be creating a `docker-compose.yml` file in which we will define the configuration of our Nginx container.

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