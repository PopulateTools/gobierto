# Server installation guide

In this tutorial we are going to show you how to install Gobierto in a simple Linux server.

**Server requirements:**

- 4 Gb RAM
- 40 Gb HD
- 2 x CPU cores

**Software requirements:**

- Linux OS (we recommend Ubuntu LTS 14.04)
- Ruby 2.3.1 (we recomend installing Ruby with [rbenv](https://github.com/rbenv/rbenv))
- Rubygems
- Postgresql
- ElasticSearch
- Memcached
- Webserver (we recommend Nginx)
- Dependencies (to be installed using `apt-get`):
  - build-essential
  - git
  - psmisc
  - gnupg
  - zip
  - ruby-dev
  - imagemagick
  - libpq-dev
  - nodejs

- PostgreSQL, ElasticSearch, Memcached and the webserver must be up and running

**External requirements:**

- Amazon AWS S3 keys
- Mailchimp API credentials (only if you want to integrate with Mailchimp)
- Rollbar, as exception notification tool (you can replace it easily)

We recommend you to prepare the credentials from these services before you continue with this
tutorial.

## Database setup

1 - Create the database:
  - `createdb gobierto`

## Application setup

_We have our preferences about which folders to use and with which permissions and users the application should be installed,
and this guide is going to follow those conventions. Feel free to adapt the guide to your infrastructure and personal perferences_.

### Setup folders

1 - Choose a destionation folder and create it. In our case, we prefer `/var/www/gobierto`:

  - `/var/www/gobierto/`
  - `/var/www/gobierto/shared
  - `/var/www/gobierto/shared/bundle
  - `/var/www/gobierto/shared/config
  - `/var/www/gobierto/shared/log
  - `/var/www/gobierto/shared/public
  - `/var/www/gobierto/shared/tmp
  - `/var/www/gobierto/shared/vendor
  - `/var/www/gobierto/releases
  - `/var/www/gobierto/repo

2 - Update `config/settings/production.yml` with:
  - the final domain (replacing `gobierto.es`)
  - Mailchimp API resource URI of the list. Leave it blank if you don't want to use Mailchimp

3 - Create `/var/www/gobierto/shared/config/database.yml` with the following content:

```yaml
production:
  adapter: postgresql
  encoding: unicode
  database: gobierto
  pool: 5
  username: postgres
  password:
```

4 - Create `/var/www/gobierto/shared/config/secrets.yml`

```yaml
production:
  secret_key_base: ''
  rollbar_access_token: ''
  elastic_url: 'http://localhost:9200'
  mailchimp_api_key: ''
  amazon_access_key: ''
  amazon_secret_key: ''
```

4.1 - Run `rake secret` in your dev environment and paste the result as `secret_key_base`

4.2 - Paste your Rollbar API key. If you don't use Rollbar, leave that variable in blank

4.3 - Update the URL of the ElasticSearch in case you use a remote server

4.4 - Paste your Mailchimp API Key

4.5 - Paste Amazon credentials

5 - Deploy the site

Back to your development environment, we are going to deploy the site, following these steps:

5.1 - Create the file `config/deploy/production.rb` based on `config/deploy/production.rb.example`,
updating the host

5.2 - Check the server configuration: `$ bundle exec cap production deploy:check`

5.3 - Deploy! `$ bundle exec cap production deploy`

5.4 - In the remote server, check that `/var/www/gobierto/current/` has been created as a symlink

Notice that you can change the way to deploy the application. We prefer [Capistrano](http://capistranorb.com) and that's the configured option, but if you want to deploy in a different way just update the code in the fork of your project and that's all.

6 - Load the data

Once the application is working in production (without working in the HTTP server yet) we need to
load the data.

Please, refer to our [README page](https://github.com/PopulateTools/gobierto/blob/master/README.md)
to understand which scripts you need to run.

Because you are in a remote server, you need to setup an environment variable named `RAILS_ENV` with
this command: `$ export RAILS_ENV=production`. This variable **must be set in our your sessions in
this remote server**.

7 - Configure and enable the server virtual host. You can use this file as template, with SSL configuration:

```
server {
  listen        80;
  server_name   *.gobierto.es;

  passenger_enabled on;
  client_max_body_size 50M;

  access_log      /var/log/nginx/presupuestos-gobierto_access.log;
  error_log       /var/log/nginx/presupuestos-gobierto_error.log;

  root /var/www/gobierto/current/public;

  rails_env production;

  # pages like /api/v1/something.xml, cached as xml
  if (-f $document_root/cache/$uri) {
    rewrite (.*) /cache/$1 break;
  }

  location ~ ^/assets/ {
    try_files $uri =404;
    expires max;
    add_header Cache-Control public;
    gzip_static on;
    add_header Last-Modified "";
    add_header ETag "";
    break;
  }

  location ~* \.(?:ico|css|js|gif|jpe?g|png)$ {
    try_files $uri =404;
    log_not_found off;
    break;
  }
}

server {
  listen 443;
  server_name   *.gobierto.es;

  ssl on;
  ssl_certificate /etc/ssl/certs/gobierto.es.chained.crt;
  ssl_certificate_key /etc/ssl/private/gobierto.key;

  passenger_enabled on;
  client_max_body_size 50M;

  access_log      /var/log/nginx/presupuestos-gobierto_access.log;
  error_log       /var/log/nginx/presupuestos-gobierto_error.log;

  root /var/www/gobierto/current/public;

  rails_env production;

  location ~ ^/assets/ {
    try_files $uri =404;
    expires max;
    add_header Cache-Control public;
    gzip_static on;
    add_header Last-Modified "";
    add_header ETag "";
    break;
  }

  location ~* \.(?:ico|css|js|gif|jpe?g|png)$ {
    try_files $uri =404;
    log_not_found off;
    break;
  }
}
```

Remember to update the domains (updating the variable `server_name`) according to your needs.

8 - Once you reload the webserver to read the new configuration you should be able to see the site up and running.

## Questions

If you have any question, please reach to us in `info@gobierto.es` or create an issue in the
repository. We'll get back to you ASAP.
