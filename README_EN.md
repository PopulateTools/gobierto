[![CircleCI](https://circleci.com/gh/PopulateTools/gobierto-dev.svg?style=svg)](https://circleci.com/gh/PopulateTools/gobierto-dev)
[![codecov](https://codecov.io/gh/PopulateTools/gobierto/branch/master/graph/badge.svg)](https://codecov.io/gh/PopulateTools/gobierto)
[![Stories in Ready](https://badge.waffle.io/PopulateTools/gobierto-dev.svg?label=ready&title=Ready)](http://waffle.io/PopulateTools/gobierto-dev)

![Gobierto](http://gobierto-populate-production.s3.amazonaws.com/sites/LogoGobierto.png)

Este README está disponible [en Español](README.md)

# Gobierto

Gobierto is a Rails app that provides a set of tools to power efforts from public administrations towards transparency and citizen engagement, to enable them to communicate better with their constituents and put public open data to work. We are getting started and many things will change. The first working module is for budget visualization. Things you can currently do with Gobierto:

1. **Single-Site for a public body (ie municipality)**: Setup a site for a municipality (such as madrid.gobierto.es) to publish their budgets in a well designed, easy to understand way. We'll be adding other modules such as budget, indicators, stories...
2. **Multi-site for public bodies**: #1, but to provide service for many bodies with the same software installation in separate URLs (madrid.gobierto.es, barcelona.gobierto.es, etc).
3. **Budget comparison**: A budgets comparison tool to enable citizens to explore, visualize, compare and contextualize the budgets of multiple municipalities/public bodies at the same time (such as those of a given Province, Autonomous Region or Country). You can check a live instance at [presupuestos.gobierto.es](http://presupuestos.gobierto.es) (it contains municipal budget data for almost 8.000 spanish municipalities). Now, this source code has been extracted from Gobierto and lives in a separated repository: [Gobierto Comparador Presupuestos](https://github.com/PopulateTools/gobierto-comparador-presupuestos).


You can use any of the three use cases independently, or all at once with the same software installation. And you don't have to be a public bobdy to use it.

Gobierto is being built in the open by [Populate](http://populate.tools), a product design studio around civic engagement based in Madrid, Spain. We provide commercial services around data journalism, news products, open data... and Gobierto, of course ;)

* #todo Why we build Gobierto and our design philosophy

More info:

* Main site (spanish): [gobierto.es](https://gobierto.es)
* Blog (spanish): [gobierto.es/blog](https://gobierto.es/blog)
* #todo public broadcast channel to report updates

## Feature requests

File an [issue](https://github.com/PopulateTools/gobierto/issues).

## Application architecture

The application is written in the Ruby programming language and uses the Ruby on Rails framework. In the database layer uses Postgres. Also, it uses an external Elastic Search to store and process all the budgets and third-party data.

The application is designed as multi-tentant, where each Site lives on its own domain and with its own configuration, both styles and modules enabled.

Modules group functionality. Currently, the modules the modules developed are:

- Budgets Visualizacion
- Observatory
- Politics and Agendas
- Plan visualization

## Docs

All documentation is available at https://gobierto.readme.io

## Contributing

Yes! See [contributing](https://github.com/PopulateTools/gobierto/blob/master/CONTRIBUTING_EN.md)

### Libraries/gems being used

* Gems: See [Gemfile](https://github.com/PopulateTools/gobierto/blob/master/Gemfile) for complete reference
* Other (CSS, JS): #ToDo (browse source meanwhile ;)

## License

Code published under AFFERO GPL v3 (see [LICENSE-AGPLv3.txt](https://github.com/PopulateTools/gobierto/blob/master/LICENSE-AGPLv3.txt))
