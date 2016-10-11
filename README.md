# Dockerized Directus with S3 support

* Create a new database or bring your own
* Easy S3 support. Just add environment variables to `docker-compose.yml`.
* Utilizes [custom nginx config](https://github.com/h5bp/server-configs-nginx).
* php-fpm 5.6, mariadb 10.1 and nginx 1.10

The goal of this is to easily create a high-performing, headless content API, with a GUI and CDN support. One that can be launched and configured easily so that you can focus on more important things. This is still a work in progress.

It assumes you're familiar with [docker-machine](https://docs.docker.com/machine/overview/) and [docker-compose](https://docs.docker.com/compose/overview/).

The best way to use this is to mount a local storage volume or add S3 credentials to send files there.

The `nginx` and `fpm` containers are provided separately for flexibility, but there's a sample `docker-compose.yml` file that's provided which should have everything you need to get up and running quickly. They are also built automatically on Docker Hub using this repo at `iamdb/nginx-directus-docker` and `iamdb/fpm-directus-docker`.

## docker-compose.yml
To get this up and running is really easy.

Just run:
```
docker-compose up
```

It will build and start all of the containers. It may take a while the first time. The `fpm` container has a lot to build. If they all build and start correctly, the `fpm` container will wait for the database host and port to become available. Once it is, and if Directus isn't already installed and all of the admin variables and the site title variable are present, a new installation using that information will be created.

## Goals

* Let's Encrypt support