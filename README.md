[![CircleCI](https://circleci.com/gh/PopulateTools/gobierto-dev.svg?style=svg)](https://circleci.com/gh/PopulateTools/gobierto-dev)


![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

___this is a development version, not ready for production___

This README is available [in English](README_EN.md)

# Gobierto

Gobierto es una aplicación Rails que proporciona una serie de herramientas a las administraciones públicas para facilitar la transparencia y la participación ciudadana, para que se comuniquen mejor con los ciudadanos y para facilitar la explotación de los datos públicos.

Gobierto está comenzando y es posible que algunas cosas cambien por el camino. El primer módulo disponible es el de Visualización de Presupuestos. Este es el tipo de cosas que puedes hacer:

1. **Sitio único para una entidad pública (por ejemplo, un municipio)**: Monta un sitio web para un Municipio (por ejemplo, madrid.gobierto.es) para publicar sus presupuestos de una manera sencilla de comprender. Pronto añadiremos otros módulos tales como Consultas de Presupuestos, Indicadores, Historias...
2. **Sitio múltiple para entidades públicas**: Como el punto 1, pero para dar servico a múltiples entidades públicas bajo la misma instalación de Software y con distintos subdominios (madrid.gobierto.es, barcelona.gobierto.es, etc). 
3. **Comparación de Presupuestos**: Una herramienta de comparación de presupuestos para que los ciudadanos puedan explorar, visualizar, comparar y poner en contexto los presupuestos de varias entidades públicas al mismo tiempo (como por ejemplo los de los municipios de una Provincia, Comunidad Autónoma o de un País). Puedes ver una instancia activa aquí [presupuestos.gobierto.es](http://presupuestos.gobierto.es) (contiene datos presupuestarios municipales para prácticamente la totalidad de los 8000 municipios en España).

Puedes usar cualquiera de los tres escenarios de forma independiente o todos a la vez bajo una única instalación. Y no tienes por qué ser una institución pública para usarlo.

Gobierto es un proyecto abierto de [Populate](http://populate.tools), un estudio que diseña desde Madrid productos digitales alrededor de la Participación Ciudadana. Además de trabajar en Gobierto, también ofrecemos servicios en torno a datos abiertos, periodismo de datos, sostenibilidad, etc.

* #todo Por qué Gobierto y nuestra filosofía de Diseño

Más información: 

* Website de Gobierto: [gobierto.es](http://gobierto.es)
* Blog: [gobierto.es/blog](http://gobierto.es/blog)
* #todo public broadcast channel to report updates

## Roadmap

[Puedes verlo en nuestro Wiki](https://github.com/PopulateTools/gobierto/wiki). (En Inglés)

## Sugerencias de Mejora

Crea un [issue](https://github.com/PopulateTools/gobierto/issues).

## Arquitectura de la aplicación

La aplicación está escrita en Ruby y usa el framework Ruby on Rails. Para la Base de Datos usa PostgreSQL y también usa ElasticSearch para almacenar toda la información de presupuestos y otros datos de terceros. El módulo de presupuestos vive bajo su propio subdominio, lo mismo que cada uno de los sites individuales para cada una de las entidades públicas. Este es el esquema que siguen los subdominios:

- `presupuestos.`, donde vive el comparador de presupuestos.
- `<entidad_publica>.`, es como empieza el dominio de cada Sitio individual para cada entidad pública donde el módulo de presupuestos y otros se pueden activar.

## Desarrollo

### Requerimientos de Software

- Git
- Ruby 2.3.1
- Rubygems
- PostgreSQL
- Elastic Search
- Pow or another subdomains tool

### Prepara la base de datos y el archivo secrets.yml

Una vez tengas PostgreSQL corriendo y hayas clonado este repo, haz lo siguiente en el terminal:

```
$ cd gobierto
$ cp config/database.yml.example config/database.yml
$ cp config/secrets.yml.example config/secrets.yml
$ bundle install
$ rake db:setup
```

### Monta una instancia de Elastic Search

Aquí puedes ver [cómo](https://www.elastic.co/guide/en/elasticsearch/guide/current/running-elasticsearch.html)

Una vez esté corriendo, asegúrate de configurar la URL correcta para tu instancia de Elastic Search en el archivo `config/secrets.yml` bajo la clave `elastic_url`

### Carga algunos datos

Si simplemente quieres cargar unos cuantos datos para empezar a trabajar, haz lo siguiente:

1. Clona [este repo](https://github.com/PopulateTools/gobierto-budgets-data) y sigue las instrucciones para que tengas todos los datos de los municipios españoles disponibles para importar.
2. Después, ejecuta `bin/rake gobierto_budgets:setup:sample_site`

Esto cargará los datos para Madrid, Barcelona y Bilbao y activará el Site de Municipio de prueba para Madrigal de la vera.

Alternativamente, aquí puedes ver [cómo cargar los datos](https://github.com/PopulateTools/gobierto/wiki/Loading-Gobierto-Data) para más municipios de España.

### Crea el subdominio y lanza la aplicación

Cuando trabajes en local, al servidor de aplicaciones se debería acceder a través del dominio `.gobierto.dev`. Para configurar esto en tu entorno, la manera más sencilla es usando [POW](http://pow.cx/). Para instalarlo:

```
curl get.pow.cx | sh
```

Después, configura el servidor así:

```
echo "3000" > ~/.pow/gobierto
```

Y simplemente navega a http://presupuestos.gobierto.dev/ para cargar la aplicación.

### Montando el site para una sóla entidad pública

Ejecuta lo siguiente:

```
bin/rake gobierto_budgets:setup:create_site['<Place ID>','<URL OF INSTITUTION>']
```
Donde `<Place ID>` es el ID del municipio que quieres montar y `<URL OF INSTITUTION>` es la URL opcional del posible site oficial de ese municipio.

## Trae tus propios datos

ToDo: Documentar el formato de datos para importar

## Contribuir

Claro! Mira [cómo contribuir](https://github.com/PopulateTools/gobierto/blob/master/CONTRIBUTING_ES.md)

### Librerías/gemas

* Gemas: Echa un vistazo a [Gemfile](https://github.com/PopulateTools/gobierto/blob/master/Gemfile) para una referencia completa
* Otras (CSS, JS): #ToDo (explora el código de momento;)

## Licencia

Software publicado bajo la licencia de código abierto AFFERO GPL v3 (ver [LICENSE-AGPLv3.txt](https://github.com/PopulateTools/gobierto/blob/master/LICENSE-AGPLv3.txt))
