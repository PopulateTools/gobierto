![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

# Gobierto

## Setting up the development environment with Docker

### Overview

1. For Linux users, we need you to install [Docker engine](https://docs.docker.com/engine/installation/) and [Docker compose](https://docs.docker.com/compose/install/). Make sure you have Docker compose version 1.6 or higher by executing

```shell
$ docker-compose version
```

2. For PC and Mac users we need you to install [Docker toolbox for Mac and Windows](https://www.docker.com/products/docker-toolbox) and use [Docker Machine](https://docs.docker.com/machine/get-started/) to create a virtual machine to run your Docker containers. Once your machine is created and you have connected your shell to this new machine, you're ready to run Docker commands on this host. If you're using Linux you can skip to the next step.

### Configuration

```shell
$ cp config/database.yml.example config/database.yml
$ cp .env.example .env
```

Fill all the values of the new `.env` file (see [environment variables description document](docs/environment-variables.md) if you need a detailed description of each variable).

If you are using **rbenv** you should:

1. Check you have [rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed
2. Symlink `.env` to `.rbenv-vars` file. Yo can do this by running:

```shell
$ ln -s .env .rbenv-vars
```

3. Verify variables are properly configured by running `rbenv vars`. You should see something like:

```shell
export INTEGRATION_DEBUG='false'
export INTEGRATION_INSPECTOR='false'
export TEST_LOG_LEVEL='debug'
export RACK_ENV='development'
export RAILS_ENV='development'
export HOST='gobierto.test'
...
```

### Set up

```shell
$ docker-compose up -d
$ docker-compose run web bundle install
$ docker-compose restart
```

If you get a "*Couldn't connect to Docker daemon - you might need to run 'docker-machine start default'.*" error when running `docker-compose up -d`, but the docker machine is indeed running, you might want to take a look at [this issue](https://github.com/docker/compose/issues/2495#issuecomment-222230768).

### Seeding the databases

```shell
$ docker-compose run web script/setup
```

### Accessing the Docker host

If you are using Docker Machine, run this command to get your current Docker host's IP:

```shell
$ docker-machine ip <your_docker_machine_name>
```

### Application server

After having started all Docker containers via the `docker-compose`
command, the application will be reachable at:
[http://\<your_docker_host\>:3000/](http://your_docker_host:3000/)

### Tests

To run the entire test suite:

```shell
$ docker-compose run test
```

### Development top-level domain and port proxying

The application server should be queried through the top-level domain `.gobierto.test`. For this purpose you could use [Pow](http://pow.cx/)'s Port Proxying feature, as described on its [User's manual](http://pow.cx/manual.html#section_2.1.4):

```shell
$ echo http://<your_docker_host>:3000 > ~/.pow/gobierto
```

So, since port `3000` is forwarded through the corresponding Docker containers, the app instance should be just reachable at [http://madrid.gobierto.test](http://madrid.gobierto.test).

### Mailcatcher

To use `MailCatcher`, make sure the `mailcatcher` container is up and running:

```shell
$ docker-compose up -d mailcatcher
```

Having done this, the server should be available at `http://<your_docker_host>:1080`.

### Using xip.io

Check how to use xip.io in https://github.com/PopulateTools/gobierto/blob/master/docs/development-environment.md
