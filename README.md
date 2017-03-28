[![CircleCI](https://circleci.com/gh/PopulateTools/gobierto.svg?style=svg)](https://circleci.com/gh/PopulateTools/gobierto)
[![codecov](https://img.shields.io/codecov/c/github/PopulateTools/gobierto.svg)](https://codecov.io/gh/PopulateTools/gobierto)
[![Stories in Ready](https://badge.waffle.io/PopulateTools/gobierto.svg?label=ready&title=Ready)](http://waffle.io/PopulateTools/gobierto)

![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

This README is available [in English](README_EN.md)

# Gobierto

Gobierto es una aplicación Rails que proporciona una serie de herramientas a las administraciones públicas para facilitar la transparencia y la participación ciudadana, para que se comuniquen mejor con los ciudadanos y para facilitar la explotación de los datos públicos.

Gobierto está comenzando y es posible que algunas cosas cambien por el camino. El primer módulo disponible es el de Visualización de Presupuestos. Este es el tipo de cosas que puedes hacer:

1. **Sitio único para una entidad pública (por ejemplo, un municipio)**: Monta un sitio web para un Municipio (por ejemplo, madrid.gobierto.es) para publicar sus presupuestos de una manera sencilla de comprender. Pronto añadiremos otros módulos tales como Consultas de Presupuestos, Indicadores, Historias...
2. **Sitio múltiple para entidades públicas**: Como el punto 1, pero para dar servicio a múltiples entidades públicas bajo la misma instalación de Software y con distintos subdominios (madrid.gobierto.es, barcelona.gobierto.es, etc).
3. **Comparador de presupuestos**: Una aplicación que permite visualizar y comparar los presupuestos de todo el país o una subregión, como puede ser una autonomía o una provincia. Puedes ver esta aplicación funcionando en [presupuestos.gobierto.es](https://presupuestos.gobierto.es). Esto es ahora mismo una aplicación separada que vive en otro repositorio: [Gobierto Comparador Presupuestos](https://github.com/PopulateTools/gobierto-comparador-presupuestos).

Puedes usar cualquiera de los tres escenarios de forma independiente o todos a la vez bajo una única instalación. Y no tienes por qué ser una institución pública para usarlo.

Gobierto es un proyecto abierto de [Populate](http://populate.tools), un estudio que diseña desde Madrid productos digitales alrededor de la Participación Ciudadana. Además de trabajar en Gobierto, también ofrecemos servicios entorno a datos abiertos, periodismo de datos, sostenibilidad, etc.

* #todo Por qué Gobierto y nuestra filosofía de Diseño

Más información:

* Website de Gobierto: [gobierto.es](http://gobierto.es)
* Blog: [gobierto.es/blog](http://gobierto.es/blog)
* #todo canal donde publicar actualizaciones

## Sugerencias de Mejora

Crea un [issue](https://github.com/PopulateTools/gobierto/issues).

## Arquitectura de la aplicación

La aplicación está escrita en Ruby y usa el framework Ruby on Rails. Para la Base de Datos usa PostgreSQL y también usa ElasticSearch para almacenar toda la información de presupuestos y otros datos de terceros.

Se trata de una aplicación multientidad, donde cada Site creado vivirá en su propio dominio y tendrá una configuración propia en cuanto a estilos y módulos que puede tener activados.

Los módulos agrupan funcionalidad, por ejemplo, los módulos actualmente desarrollados son:

- Visualización de Presupuestos
- Consultas sobre Presupuestos
- Altos Cargos y Agendas
- Indicadores

En desarrollo ahora mismo:

- Participación Ciudadana

## Desarrollo

Si quieres instalarte Gobierto en tu propio entorno o desarrollar algún módulo nuevo, aquí tienes una serie de páginas enlazadas con toda la información que te hará falta.

- Configurar el entorno de desarrollo [con Docker](docs/development-environment-docker.md) o [sin Docker](docs/development-environment.md)
- [Variables de entorno](docs/environment-variables.md)
- [Acceder como Administrador](docs/admin-namespace.md)
- [Acceder como Usuario](docs/user-namespace.md)
- [Integrar la extensión Trackable](docs/trackable-extension.md)
- [Integrar el componente DynamicContent](docs/dynamic-content-component.md)
- [Desarrollar un módulo](docs/developing-module.md)

## Contribuir

Sí! Mira [cómo contribuir](https://github.com/PopulateTools/gobierto/blob/master/CONTRIBUTING_ES.md)

## Licencia

Software publicado bajo la licencia de código abierto AFFERO GPL v3 (ver [LICENSE-AGPLv3.txt](https://github.com/PopulateTools/gobierto/blob/master/LICENSE-AGPLv3.txt))
