
![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

Este README está disponible [en Español](README.md)

# Gobierto

Gobierto is a Rails app that provides a set of tools to power efforts from public administrations towards transparency and citizen engagement, to enable them to communicate better with their constituents and put public open data to work. We are getting started and many things will change. The first working module is for budget visualization. Things you can currently do with Gobierto:

1. **Single-Site for a public body (ie municipality)**: Setup a site for a municipality (such as madrid.gobierto.es) to publish their budgets in a well designed, easy to understand way. We'll be adding other modules such as budget consultations, indicators, stories...
2. **Multi-site for public bodies**: #1, but to provide service for many bodies with the same software installation in separate URLs (madrid.gobierto.es, barcelona.gobierto.es, etc). 
3. **Budget comparison**: A budgets comparison tool to enable citizens to explore, visualize, compare and contextualize the budgets of multiple municipalities/public bodies at the same time (such as those of a given Province, Autonomous Region or Country). You can check a live instance at [presupuestos.gobierto.es](http://presupuestos.gobierto.es) (it contains municipal budget data for almost 8.000 spanish municipalities).

You can use any of the three use cases independently, or all at once with the same software installation. And you don't have to be a public bobdy to use it. 

Gobierto is being built in the open by [Populate](http://populate.tools), a product design studio around civic engagement based in Madrid, Spain. We provide commercial services around data journalism, news products, open data... and Gobierto, of course ;) 

* #todo Why we build Gobierto and our design philosophy

More info: 

* Main site (spanish): [gobierto.es](http://gobierto.es)
* Blog (spanish): [gobierto.es/blog](http://gobierto.es/blog)
* #todo public broadcast channel to report updates

## Roadmap

[See our wiki](https://github.com/PopulateTools/gobierto/wiki). 

## Feature requests

File an [issue](https://github.com/PopulateTools/gobierto/issues). 

## Application architecture

The application is written in the Ruby programming language and uses the Ruby on Rails framework. In the database layer uses Postgres. Also, it uses an external Elastic Search to store and process all the budgets and third-party data. Gobierto budgets module lives in its own subdomain, and so does each of the individual sites for public bodies. This is the subdomains schema:

- `presupuestos.`, where Gobierto Budget Comparison lives
- `<public_entity_name>.`, is the public entity page where budgets visualization and other modules can be activated

## Development

### Software Requirements

- Git
- Ruby 2.3.1
- Rubygems
- PostgreSQL
- Elastic Search
- Pow or another subdomains tool

### Setup the database and the secrets file

Once you have PostgreSQL running and have cloned the repository, do the following:

```
$ cd gobierto
$ cp config/database.yml.example config/database.yml
$ cp config/secrets.yml.example config/secrets.yml
$ bundle install
$ rake db:setup
```

### Setup Elastic Search

See [how](https://www.elastic.co/guide/en/elasticsearch/guide/current/running-elasticsearch.html)

Once it is running, make sure you enter the correct URL for your Elastic Search instance in `config/secrets.yml` under the `elastic_url` key

### Load some data

If you want to import some basic data to get started, do the following:

1. Clone this repo and follow the instructions in order to have all of the Spanish Budgetary data available to load.
2. Run `bin/rake gobierto_budgets:setup:sample_site`

This will load data for Madrid, Barcelona and Bilbao and setup a site for Madrigal de la Vera.

Alternatively, learn [how to load the data](https://github.com/PopulateTools/gobierto/wiki/Loading-Gobierto-Data) for all or some municipalities in Spain.

### Setup subdomain and start the application

When working locally, the application server should be queried through the top-level domain `.gobierto.dev`. To configure this host in your computer, the simplest way is through POW [POW](http://pow.cx/). To install:

```
curl get.pow.cx | sh
```

Then, configure the host like this:

```
cd ~/.pow
ln -s DIRECTORY/gobierto gobierto
```

Then just browse to http://presupuestos.gobierto.dev/ and the app should load.

### Setting up the site for a single public entity

Run:

```
bin/rake gobierto_budgets:setup:create_site['<Place ID>','<URL OF INSTITUTION>']
```
Where `<Place ID>` is the ID of the municipality you wish to setup the site for and the optional `<URL OF INSTITUTION>` is the URL for other municipality's website, if any.

## Bring your own data

ToDo: Document the format of budget data needed to import it.

## Contributing

Yes! See [contributing](https://github.com/PopulateTools/gobierto/blob/master/CONTRIBUTING_EN.md)

### Libraries/gems being used

* Gems: See [Gemfile](https://github.com/PopulateTools/gobierto/blob/master/Gemfile) for complete reference
* Other (CSS, JS): #ToDo (browse source meanwhile ;)

## License

Code published under AFFERO GPL v3 (see [LICENSE-AGPLv3.txt](https://github.com/PopulateTools/gobierto/blob/master/LICENSE-AGPLv3.txt))
