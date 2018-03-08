![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

# Gobierto

## Setting up the development environment

### Overview

* This guide assumes you are using macOS and have [Homebrew](https://brew.sh/) installed.
* Some of these steps might be incompatible with the [Docker setup approach](development-environment-docker.md).
* The main dependencies are:
 * *postgres*
 * *redis*
 * *elasticsearch*

### Ruby

Gobierto is a [Ruby on Rails application](http://rubyonrails.org) so you need to install Ruby first.
You can check [here](https://github.com/PopulateTools/gobierto/blob/master/.ruby-version) which
version of Ruby is the current one.

To install Ruby we recommend a Ruby version manager, such as [rvm](http://rvm.io) or
[Rbenv](https://github.com/rbenv/rbenv) (our preferred choice).

After installing the Ruby version manager, install the gem bundler: `gem install bundler` and you
are ready for the next steps.

### Postgres

First install postgres with:

```shell
brew install postgres
```

Once installed, we need to *initialize* it:

```shell
initdb /usr/local/var/postgres
```

Now we're going to configure some things related to the *default user*. First we start the postgres server with:

```shell
postgres -D /usr/local/var/postgres
```

At this point we're supposed to have postgres correctly installed and a default user will automatically be created (whose name will match our username). This user hasn't got a password yet.

If we run `psql` we'll login into the postgres console with the default user. Probably it will fail since its required that a default database exists for that user. We can create it by typing:

```shell
createdb 'your_username'
```

If we run `psql` again we should now get access to postgres console. With `\du` you can see the current users list.

Now create the gobierto database user with the `createuser` command (this is done **outside** the `psql` console):

```shell
createuser --createdb --login -P gobierto
# => Password: gobierto
```

You'll also need to chage this user's role to superuser:

```shell
# Fist brig up the psql console with:
psql

# And then run:
ALTER USER gobierto WITH SUPERUSER;
```

Now fill `config/database.yml` with the corresponding database credentials:

```yaml
default: &default
  username: gobierto
  password: gobierto
```

You can remove: `host` and `url`.

Now run:

```shell
bin/rails db:setup
```

### Redis

First install redis with:

```shell
brew install redis
```

Now start the redis server using a configuration file:

```shell
redis-server /usr/local/etc/redis.conf
```

* The redis server will start to listen to connections on `127.0.0.1:6379`

Complete the `REDIS_URL` line inside the `.env` file with the following value:

```shell
REDIS_URL=redis://redis:6379
```

* Useful resources - [Redis setup](https://medium.com/@petehouston/install-and-config-redis-on-mac-os-x-via-homebrew-eb8df9a4f298#.9sky45p09)


### ElasticSearch

First install elasticsearch **`2.4`** with:

```shell
brew install elasticsearch@2.4
```

* **NOTE**: elasticsearch `5.2.1` does not work right now.

Then you can start it by typing:

```shell
brew services start elasticsearch@2.4
```

Complete the `ELASTICSEARCH_URL` line inside the `.env` file with the following value:

```shell
ELASTICSEARCH_URL=http://elasticsearch:9200
```

And the `elastic_url` key inside the `config/secrets.yml` file:

```yaml
default: &default
  elastic_url: http://localhost:9200
```

### Application configuration

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

### Development top-level domain and port proxying

Gobierto is a [_multi-tenant_](https://en.wikipedia.org/wiki/Multitenancy) application, designed to serve multiple *tenants* from the same instance of the application. A tenant is a group of users who share a common access with specific privileges to the software instance. In our case these tenants are the different cities using Gobierto.

When running a single Gobierto rails application, you'll be able to access each of the available tenants throught a custom URL. The easiest way to deal with this is to use [Pow](http://pow.cx/)'s Port Proxying feature, as described on its [User's manual](http://pow.cx/manual.html#section_2.1.4).

Once Pow is installed, you have to configure it to work with Gobierto:

```shell
cd ~/.pow
echo 3000 > ~/.pow/gobierto
```

The seeds provided for development, as explained [here](user-namespace.md), have two available tenants: one for the city of Madrid and one for Santander.

The application server should be queried through the top-level domain `.gobierto.test`. Each of the tenants are accessible on their corresponding subdomais:

* [http://madrid.gobierto.test](http://madrid.gobierto.test)
* [http://santander.gobierto.test](http://santander.gobierto.test)

### PhantomJS

PhantomJS is a headless browser to run end to end tests. Install it with your package manager. I.e: `brew install phantomjs`.

### Run the tests!

Now you can run the tests with:

```shell
./script/test
```

* **NOTE**: it is not enough to run `bin/rails test` since the test script contains a few more necessary steps.

### Mailcatcher

To use `MailCatcher`, just run `$ mailcatcher` command and follow the instructions printed in the terminal.

### Using xip.io

[xip.io](http://xip.io) is a magical DNS that allows us to expose our local server to external devices, such as other computers or mobile devices. It's very useful to check the dev server in a mobile.

Just follow the following steps:

1. Figure out your LAN IP, in your _Network preferences_ or just by doing in the shell: `ifconfig | grep 192`.  Let's say it's `192.168.1.41`, it means that Gobierto will be visible in `*.192.168.1.41.xip.io`
2. Log into your Gobierto instance and edit the site you want to expose, by updating the domain to something like `madrid.gobierto.test.192.168.1.41.xip.io`
3. Stop the rails server and start it again with a new parameter to bind it to any address: `rails s -b 0.0.0.0`
4. That's all, now you can visit http://madrid.gobierto.test.192.168.1.41.xip.io:3000/ in any device

### Open Gobierto

Now you can start using Gobierto:

1. Start the server with `bin/rails s`
2. Go to http://madrid.gobierto.test to see a demo site
3. Go to the administrator: http://madrid.gobierto.test/admin
4. See [admin namespace](admin-namespace.md) for some admin credentials
5. See [user namespace](user-namespace.md) for some user credentials
