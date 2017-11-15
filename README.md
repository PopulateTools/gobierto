[![CircleCI](https://circleci.com/gh/PopulateTools/gobierto.svg?style=svg)](https://circleci.com/gh/PopulateTools/gobierto)
[![codecov](https://codecov.io/gh/PopulateTools/gobierto/branch/master/graph/badge.svg)](https://codecov.io/gh/PopulateTools/gobierto)


<img src="https://gobierto.es/assets/logo_gobierto.png" width="250" height="auto">

_This README is available [in English](README_EN.md)_

Gobierto es una plataforma de gobierno abierto de código libre. Ofrece herramientas de transparencia, participación y rendición de cuentas para administraciones públicas y otras organizaciones que quieran abrirse.

* [Filosofía y principios de diseño](#filosofía-y-principios-de-diseño)
* [Qué ofrece](#qué-ofrece)
* [Características técnicas](#características-técnicas)
* [Quién lo usa](#quién-lo-usa)
* [Quiénes somos](#quiénes-somos)
* [Comienza a usarlo](#comienza-a-usarlo)
* [Síguenos](#síguenos)
* [Manuales](#manuales)
* [Instalación, desarrollo y contribuciones](#instalación-desarrollo-y-contribuciones)
* [Licencia](#licencia)

## Filosofía y principios de diseño

- **Modular y eficiente**: uno de los objetivos de Gobierto es conseguir una implementación eficiente - puedes arrancar usando un solo módulo, e ir activando y personalizando nuevos módulos poco a poco. No necesitas instalar una aplicación diferente para cada servicio que quieras poner en marcha, con el consiguiente ahorro de tiempo y dinero y la mejora de la experiencia del usuario.
- **Foco en el uso**: Los fundadores del proyecto tenemos una larga trayectoria en el diseño de productos digitales y aplicamos
- **Abierto e interoperable**: Gobierto está diseñado para conectarse con sistemas externos - ej. portales de open data para reutilizar la información presupuestaria, sistemas de SSO para identificar y verificar a los usuarios en procesos participativos, las agendas de cargos y directivos, etc.
- **Transparencia legalista vs. transparencia útil**: Gobierto da respuesta a las exigencias de la Ley de Transparencia, pero no se para en cumplir una lista de requisitos, si no de ofrecer utilidad real para los ciudadanos y permitir a las administraciones conectar con ellos.
- **Involucración progresiva**: todavía no existe un modelo mental  sobre transparencia y participación. No hay expectativas claras ni sabemos qué esperar si participamos. Tan importante es poner en marcha iniciativas, como conseguir comunicarlas e involucrar a los destinatarios. Y pensamos que esto se consigue ofreciendo mecanismos de involucración progresiva.
- **Transición off-on**: La participación offline especialmente a nivel local tiene muchos años de trayectoria. Pensamos que las herramientas online deben ser una extensión, apoyo y complemento de procesos y metodologías que ya pueden estar en marcha.
- **Largo plazo**: pensamos que el camino hacia la transparencia y la participación online es un largo recorrido que apenas hemos comenzado. Las iniciativas a poner en marcha ahora no serán las mismas que dentro de 10 años. Nos configuramos para estar aquí entonces.

## Qué ofrece

- **Visualización de presupuestos**: haz tus presupuestos comprensibles por la ciudadanía y permite seguirlos.
- **Personas y agendas**: muestra el organigrama de tu organización y los datos clave de las personas (biografía, curriculum, declaraciones de bienes y actividades...). Sincroniza las agenda de los cargos, modera el contenido, y permite hacer un seguimiento de los eventos.
- **Indicadores estadísticos - Tu entidad en cifras**: Visualiza de forma comprensible los principales indicadores estadísticos de tu municipio - población, empleo, economía, criminalidad...
- **Consultas sobre presupuestos**: consulta a tus vecinos y consigue opiniones sobre los temas que más les preocupan para _informar_ tus decisiones presupuestarias y aumentar tu legitimidad.
- **Participación**: Diseña procesos de participación para que el _online_ sea una extensión y complemento de tus iniciativas actuales. Herramientas de debate, consultas, votación, anotación de textos...
- **Legislación colaborativa**: involucra a los ciudadanos en la redacción o modificación de normativa.
- **Plan de gobierno y objetivos**: Permite explorar tu programa de gobierno en proyecto clasificados por áreas, ámbitos... Haz rendición de cuentas informando periódicamente sobre el progreso  en su implementación.  
- **Mapas**: a veces no es fácil disponer de un visor GIS simple de usar. Gobierto se conecta a tu open data para ofrecerte un visor web GIS que se puede usar.
- **Comparador de presupuestos**: compara, contextualiza y analiza el presupuesto de entidades equivalentes (de un conjunto de municipios, por ejemplo)
- ... y más que irán llegando. ¿Tienes algo en la cabeza? ¡Hablemos!


Funcionalidades transversales:

- **CRM (Citizen Relationship Manager)**: Permite a los usuarios suscribirse a cualquier contenido y recibir resumen de las novedades: cuando se actualicen los presupuestos, cuando haya nuevos eventos en las agendas, cuando un cargo actualice su declaración de bienes, cuando se publiquen resultados de un plan de acción... Alertas personalizables por temáticas y ámbitos geográficos.
- **SSO (Single Sign On) y conexión con censo**
- **Gestión de usuarios**
- **Personalización de sitios**


## Características técnicas

- Desarrollado con Ruby on Rails, Postgresql, SASS
- Multientidad: una misma instalación da soporte a sites independientes.
- Responsive: diseñado para funcionar en desktop, móvil, tableta...
- Modo SAAS: como parte de nuestra oferta de servicios profesionales, te lo ofrecemos en modo servicio para hacer todavía más eficiente y económica la puesta en marcha.

## Quién lo usa

Estas son algunas de las organizaciones que usan Gobierto:

* [Diputación de Valencia](https://gobierto.es/blog/20161215-diputacion-de-valencia-gobierto.html)
* [Sencelles](https://gobierto.es/blog/20170314-sencelles-consultas.html)
* [Generalitat de Catalunya](https://gobierto.es/blog/20170126-generalitat-catalunya.html)
* [Sant Feliu de Llobregat](https://pressupost.santfeliu.cat/)

## Quiénes somos

Gobierto es un producto de Populate, un estudio de diseño y tecnología en torno al civic engagement. Más información en nuestra web: [populate.tools](https://populate.tools)


## Comienza a usarlo

* Puedes instalar Gobierto y personalizarlo para tu organización: [Instalación](#instalación) (inglés). Si te encuetras con alguna dificultad, [crea una _issue_](issues/new).
* Populate ofrece servicios comerciales para la implementación de Gobierto. Si nos necesitas, [danos un toque](https://populate.tools/es/about/#como-trabajamos).


## Síguenos

- Twitter: [@gobierto](https://twitter.com/gobierto) & [@populate_](https://twitter.com/populate_)
- Web + Blog: [gobierto.es(https://gobierto.es)

### Manuales

- [Manual del Administrador](docs/manual_admin.md)

## Instalación, Desarrollo y contribuciones

Toda la documentación y comunicación relativa al desarrollo la realizamos en inglés.

### Instalación

- Configurar el entorno de desarrollo [con Docker](docs/development-environment-docker.md) o [sin Docker](docs/development-environment.md)
- [Variables de entorno](docs/environment-variables.md)
- [Acceder como Administrador](docs/admin-namespace.md)
- [Acceder como Usuario](docs/user-namespace.md)


### Desarrollo

- Contribuciones: Si quieres realizar aportaciones a Gobierto, lee [cómo colaborar](CONTRIBUTING_EN.md)
- [Desarrollar un módulo](docs/developing-module.md)
- [Integrar la extensión Trackable](docs/trackable-extension.md)
- [Integrar el componente DynamicContent](docs/dynamic-content-component.md)
- [Integrar plantillas con Liquid](docs/liquid-templates.md)


## Licencia

Software publicado bajo la licencia de código abierto AFFERO GPL v3 (ver [LICENSE-AGPLv3.txt](https://github.com/PopulateTools/gobierto/blob/master/LICENSE-AGPLv3.txt))
