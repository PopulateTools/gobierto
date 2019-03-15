Índice:

* [Introducción](#introducción)
* [Crear y personalizar un nuevo sitio](#crear-y-personalizar-un-nuevo-sitio)
* [Usuarios](#usuarios)
* [Módulos](#módulos)
  * [CMS](#cms)
  * [Altos Cargos y Agendas](#altos-cargos-y-agendas)
  * [Presupuestos](#presupuestos)
  * [Consultas sobre presupuestos](#consultas-sobre-presupuestos)
  * [Observatorio](#observatorio)
  * [Planes](#planes)
* Preguntas frecuentes

***

## Introducción

Gobierto es una plataforma de gobierno abierto de código libre. Tienes más información en la [página de Github del proyecto](http://github.com/populatetools/gobierto/). Este documento describe el funcionamiento de Gobierto desde el punto de vista del administrador que configura y gestiona los sitios.

### Acceso al interfaz de administración

Una misma instalación de Gobierto permite gestionar sitios que funcionan de forma independiente. El interfaz de administración permite gestionar el contenido y las funcionalidades de uno o varios sitios de Gobierto de la misma instalación, de acuerdo a los permisos de cada administrador.

Para acceder, introduce tu **correo-e** y **contraseña** en la URL de administración que te ha sido proporcionada.

### Tipos de administradores y sistema de permisos

Gobierto funciona con un sistema de permisos y tipos de administradores que permite controlar a qué sitios y módulos accede cada administrador. De esta forma, se puede crear un administrador global que pueda gestionar todos los sitios de una instalación y crear nuevos sitios, y administradores limitados a gestionar un sitio específico.

Existen dos tipos de administradores:

- **Administrador _manager_**: Accede a todos los sitios y módulos disponibles. Tiene privilegios para crear cualquier tipo de administrado y para asignarles permisos.
- **Administrador _regular_**: Accede a los sitios y módulos a los que un administrador _manager_ le ha dado acceso.

Es decir, si quieres crear un administrador que gestione un único sitio, debes asignarle el rol de **administrador _regular_** y darle permisos para administrar el sitio en cuestión.

### Un vistazo al interfaz de administración

El interfaz de administración tiene tres elementos principales:

- **Cabecera**
- **Menú lateral**
- **Espacio central**

#### Cabecera

- **Inicio**: El logo de Gobierto (esquina superior izquierda) te permite ir a la **página de inicio** del interfaz de administración.
- **Menú Red**: Ver todos los sitios a los que tienes acceso y accede al que necesites.
- **Indicador de sitio**: A la derecha del menú “Red” se indica el sitio en el que estás trabajando actualmente (ej: “Diputación de Valencia”).
- **Ver sitio**: Accede a la parte pública del sitio en el que estás trabajando actualmente.
- **Menú personal**: Para seleccionar el idioma del interfaz de administración o cerrar sesión.

#### Menú lateral

En primer lugar aparecen los **módulos** a los que tienes acceso. Selecciona uno y podrás trabajar con él en el espacio central.

**Usuarios**: Accede a las opciones de todos los usuarios y administradores.

**Personalizar sitio**: Configura distintos aspectos del sitio en el que estás trabajando actualmente, como el HTML de cabecera o el código de Google Analytics.

#### Espacio central

Este es el espacio de trabajo principal de los distintos **módulos**. Selecciona un módulo en el menú lateral y sus opciones aparecerán aquí.

Si no tienes seleccionado ningún módulo se visualiza el **Log de actividades** de todos los usuarios de tu instalación de Gobierto.

## Crear y personalizar un nuevo sitio

Aviso: Sólo los administradores de tipo _manager_ pueden crear un nuevo sitio.

Un **sitio** reúne todas las herramientas y funcionalidades disponibles para una organización determinada.

**Crear un nuevo sitio**:

1. Desde el **menú “Red”** (parte superior izquierda) haz click en “**Gestionar sitios**”
1. Haz click en “**Crear sitio**” (parte superior derecha).
1. Rellena los campos con la información del nuevo sitio.

**Campos con información del sitio**:

- **Nombre del sitio**: Información que aparece como título de ventana o pestaña del navegador. Ejemplo: “Transparencia y Participación de Madrid”
- **Nombre de la entidad**: Nombre real de la entidad, por ejemplo: “Ayuntamiento de Burjassot”.
- **Municipio**: Escribe las primeras letras del municipio y se desplegará un menú con los nombres disponibles. Selecciona el nombre que corresponda a tu municipio. No introduzcas una variación del nombre manualmente: selecciona la opción ofrecida. Ejemplo: Si al escribir “Alican..” aparece “Alicante/Alacant”, selecciona esta opción. Algunos módulos –como el de presupuestos y el de indicadores– cargan por defecto datos reales de tu municipio. Estos datos provienen, o bien de tu propia entidad (vía API o _web service_), o de fuentes oficiales (recopilados por Gobierto y almacenados en [Populate Data](http://populate.tools/)). Cuando selecciones el nombre de tu municipio, los datos se cargarán de forma automática.
- **Dominio**: El dominio o subdominio a través del cual se accederá al sitio. Las DNSs para este dominio deben estar correctamente configuradas para apuntar al subdominio de redirección de la instalación de Gobierto.
- **Logotipo**: Selecciona una imagen de tu equipo para el logotipo. El tamaño recomendado para la imagen es de 275x90px, en formato PNG con fondo transparente.
- **HTML de cabecera**: Introduce aquí el código HTML que quieras que se incluya dentro de la etiqueta <head> de la página principal.
- **HTML de pie**: Introduce aquí el código HTML correspondiente al pie de la web de tu entidad.
- **HTML de enlaces**: Los enlaces en formato HTML que aparecerán en la barra superior de tus páginas públicas, para enlazar de vuelta a la página principal de tu organización.
- **Código de Google Analytics**: Introduce el **código de seguimiento de Google Analytics** para registrar toda la actividad del sitio. Si no sabes cual es el código, consulta con la persona encargada de tu entidad o echa un vistazo a la [ayuda de Google Analytics](https://support.google.com/analytics/answer/1008080).
- **Página de privacidad**:
- **Idiomas disponibles**: Marca una casilla por cada idioma que quieras que esté disponible en tu sitio. Los módulos de Gobierto son multi-idioma, así que las opciones idiomáticas que definas aquí aparecerán cuando tengas que introducir o editar contenido en los módulos.
- **Idioma por defecto**: Selecciona el idioma con el que se cargará el sitio por defecto.
- **Módulos activados para este sitio**: Activa o desactiva módulos para tu sitio. Lo habitual es que todos los módulos disponibles estén activados. Aviso: Sólo los administradores de tipo “Manager” pueden modificar el acceso a los módulos.

## Usuarios

Los **usuarios** son los perfiles de todas las personas que usan tus sites de Gobierto. Selecciona **Usuarios** en el **menú lateral** para gestionarlos en el **espacio central**.

Existen dos tipos de perfiles: los **usuarios** y los **administradores**. Puedes seleccionar uno u otro cambiando entre las pestañas de **Usuarios** y **Administradores**.

**Usuarios**: Son aquellos que se registran en la página web, bien sea directamente a través de un formulario de registro en la página o a través de un *_web service_*.
**Administradores**: Son aquellos que tienen acceso al interfaz de administración. Pueden ser de dos tipos:
- **Administrador _manager_**: Accede a todos los sitios y módulos disponibles. Tiene poder para crear cualquier tipo de administrador, así como para asignarles permisos.
- **Administrador _regular_**: Accede sólo a los sitios y módulos a los que el manager le ha dado acceso.

### Usuarios

Los **usuarios** son aquellos perfiles que se registran en la página web, bien sea directamente a través de un formulario en la página, o a través de otra herramienta externa conectada con Gobierto. Por ejemplo, el SSO (_single sign on_) de la entidad o cualquier otro _web service_. Los usuarios no tienen acceso al interfaz de administración.

Por ejemplo, en el caso de una administración pública, un usuario es un ciudadano que se registra en la página para recibir alertas de contenido o para participar en cualquier tipo de proceso participativo o encuesta.

Para acceder a la lista de usuarios selecciona **Usuarios** en el menú lateral y bajo la pestaña **Usuarios** aparecerá el listado de todos los usuarios registrados.

Opciones del listado de usuarios:

- Haz click en el nombre del usuario (la primera columna de la tabla) para [**editar un usuario**](#cómo_editar_un_usuario).
- Haz click en la dirección de correo electrónico para enviar un correo a ese usuario.
- Haz click en “Ver usuario” para consultar datos de actividad: cuándo tuvo lugar el último login de este usuario, cuándo se registró y cuál es su sitio de origen.

#### Identificación y verificación del usuario

Los usuarios se registran en la web introduciendo su correo-e y una contraseña. El sistema les envía un correo para que confirmen su suscripción y de esta forma asegurar que son dueños del correo-e con el que se han registrado.

**Identificación**: Para identificarse, los usuarios tienen que introducir su correo-e y contraseña en la web. Si el usuario ha olvidado la contraseña, tiene una opción de recuperación automática, pero un administrador también puede cambiar su contraseña manualmente o reenviarle un correo para que elija una nueva contraseña. Esto se puede hacer [**editando ese usuario**](#cómo_editar_un_usuario), es decir, pinchando en el nombre de ese usuario en la tabla.

**Verificación**: Cualquier usuario se puede registrar en la web. Pero sólo los usuarios verificados pueden participar en aquellas áreas reservadas para usuarios verificados (como una consulta que exija garantizar que los participantes están empadronados en un municipio en concreto).

La verificación se puede realizar de varias formas dependiendo de las necesidades de la entidad. Por ejemplo, mediante conexión con un _web service_ externo que coteje los datos del usuario con una base de datos del censo, un certificado digital, etc. Como mecanismo básico Gobierto ofrece la posibilidad de cargar un **archivo de censo** para verificar usuarios.

**Cargar censo**

1. Accede al menú principal de usuarios. Selecciona **Usuarios** en el menú lateral y después la pestaña **Usuarios**.
1. Selecciona “Censo” en la parte superior derecha de la tabla y en la pantalla siguente selecciona **“Cargar archivo de censo”**.

Una vez que se añada un archivo de censo, el sistema pedirá que los usuarios se verifiquen contra este archivo para poder realizar determinado tipo de acciones (por ejemplo, participar en una consulta o un proceso participativo). La verificación consistirá en que el usuario complete de forma correcta algunos datos (DNI, fecha de nacimiento…); el sistema dará al usuario por verificado si los datos están presentes en este archivo y no han sido verificados para otro usuario. El archivo a cargar debe ser un CSV, sin fila de cabecera, con las columnas de datos que queramos que el usuario deba verificar. Por ejemplo, si queremos que valide DNI y fecha de nacimiento, deberemos preparar un fichero como este:

```
51000000W,12-05-1975
49000000W,25-01-1985
34000000W,04-12-1995
...
```
#### Cómo editar un usuario:

1. Selecciona **Usuarios** en el menú lateral.
1. Selecciona la pestaña **Usuarios**. Aparecerá una tabla con todos los usuarios registrados.
1. Haz click en el **nombre del usuario** (la primera columna de la tabla) para editarlo.

En la pantalla de edición de usuario puedes modificar varios campos. Pincha en **Actualizar** cuando hayas terminado.
- **Nombre**: nombre y apellidos del usuario
- **Email**: Correo electrónico del usuario
- **Contraseña**: Cambia directamente la contraseña del usuario con **Cambiar contraseña** o selecciona **Reenviar email de bienvenida** para enviar un correo al usuario con un enlace para cambiarla.

### Administradores

Los administradores son aquellos que tienen acceso al interfaz de administración y pueden introducir y modificar información en cada módulo. Pueden ser de dos tipos:

- **Administrador _manager_**: Accede a todos los sitios y módulos disponibles. Tiene poder para crear cualquier tipo de administrador, así como para asignarles permisos.
- **Administrador _regular_**: Accede sólo a los sitios y módulos a los que el manager le ha dado acceso.

Para acceder a la lista de administradores:

1. Selecciona **Usuarios** en el menú lateral
1. Selecciona la pestaña **Administradores**.

Opciones de la tabla de administradores:

- Haz click en el nombre del administrador para [editarlo](#cómo_crear_y_editar_un_administrador).
- Haz click en la dirección de correo electrónico para enviar un correo a ese administrador.
- Haz click en **Ver administrador** para consultar datos de actividad: cuándo tuvo lugar el último login de este administrador y cuándo se registró.

#### Crear y editar un administrador

Aviso: Sólo los administradores de tipo _máster_ pueden crear otros administradores.

##### Creación y edición directa

1. Selecciona **Usuarios** en el menú lateral.
1. Selecciona la pestaña **Administradores**.
1. Selecciona **Nuevo administrador** en la parte superior derecha de la tabla para crear uno nuevo, o bien haz click en el **nombre del administrador** para editarlo.

En la pantalla de creación/edición de administrador puedes modificar varios campos. Pincha en **Crear** o **Actualizar** cuando hayas terminado.

- **Nombre**
- **Email**
- **Contraseña**
- **Permisos**: Proporciona acceso a los distintos módulos, en el caso de que tu instalación tenga acceso a varios.
- **Sites con acceso**: Proporciona acceso a los distintos sitios, en el caso de que tu instalación tenga acceso a varios.
- **Log de actividad**

- **Regular / Manager / Deshabilitado**: Define qué tipo de permisos tiene el administrador que estás creando/editando. Selecciona “Regular” o “Manager” en la parte derecha de la pantalla (sobre el botón “Crear”). También puedes deshabilitar por completo a ese administrador.

##### Creación mediante invitación

1. Selecciona **Usuarios** en el menú lateral.
1. Selecciona la pestaña **Administradores**.
1. Selecciona **Enviar invitaciones** en la parte superior de la tabla, al lado del botón de “Nuevo administrador”
1. Introduce todos los correos electrónicos (separados por comas) de las personas a las que quieras enviar una invitación.
1. En el caso de que dispongas de varios sites, marca los que quieras dar acceso a tu(s) usuario(s) en la lista de **Sites con acceso**.
1. Selecciona **Enviar invitaciones**.



## Módulos

### CMS

El módulo de CMS permite gestionar páginas de contenido, las colecciones en las que cada página se inserta, y secciones de contenido (agrupaciones arbitrarias de páginas de cualquier colección). El módulo de CMS se puede utilizar para:

- crear páginas sencillas e independientes (cómo las condiciones de uso, términos legales, o una página con indicaciones de contacto)
- crear una colección de páginas como una sección de preguntas frecuentes con varias páginas, un portal de transparencia, una sección de ayuda, etc.

Conceptos principales: 

- Página: unidad de contenido
- Colección: agrupación básica de páginas. Cualquier página estará dentro de una colección
- Sección: agrupación arbitraria de páginas. Una vez que has creado una colección, si quieres organizar sus páginas de una forma especial (definiendo la página principal, secciones, subsecciones, etc) deberás crear una Sección. 

#### Cómo crear y editar una página

1. Si no existe una colección, deberemos crear una (desde CMS, pinchar en Colecciones - Nueva). Una vez que estamos una colección determinada, podremos ver un listado de todas sus páginas o añadir una nueva.
1. Selecciona **Nueva** o pincha en el **Título de la página** en la tabla para editarla.
1. Sobre el Título hay un **Selector de idioma**. Cada página es multi-idioma: puedes editar tantas versiones distintas de la misma página como idiomas tenga tu sitio (puedes definir estos idiomas en **Personalizar sitio** en el [menú lateral](#menú_lateral)). Selecciona un idioma para escribir la versión de tu contenido en ese idioma. Aviso: Si haces el contenido en un idioma y dejas el otro sin rellenar, la página se visualizará en el idioma que tenga contenido, independientemente de la elección del usuario. Ejemplo: Si rellenas sólo el contenido en castellano, cuando un usuario seleccione Inglés como idioma del sitio, el contenido de esa página se visualizará en castellano.
1. Rellena la información de la página. Por defecto, todas las páginas se marcan como **Borrador** (en la parte superior derecha de la pantalla) para que no se hagan públicas inmediatamente. Si quieres hacerla pública, selecciona **Publicada** y se publicará cuando apruebes los cambios en el paso siguiente.
1. Dale a **Crear** o **Actualizar** para aprobar todos los cambios.

#### Tags de Liquid

Dentro del contenido de una página puedes utilizar algunos tags de Liquid. Consulta la [página sobre Liquid](liquid-templates.md) para más información (en inglés). 


Opciones en la columna derecha: 

#### Sección

Al marcar la opción **Incluir en sección** aparecerá un menú desplegable de todas las secciones disponibles para este sitio. Cuando se seleccione una página de este primer menú, se mostrarán las subpáginas que este tiene a su vez. De esta forma se puede elegir la página padre de la página que estamos editando. 

#### Documentos

Puedes incluir archivos e imágenes a una página. Haz click en **Incluir archivo**:

- Se desplegará una ventana que muestra los últimos archivos que se han subido. Pinchando en uno de ellos, se incluirá en la página. 
- Puedes subir un nuevo archivo desde tu disco duro pinchando en el botón **Incluir archivo** de la parte derecha de la ventana que se ha desplegado. 

Una vez que has incluído un archivo en la página, podrás copiar su URL o incluir automaticamente una referencia en el texto.


### Altos Cargos y Agendas

El módulo de Altos cargos y Agendas contiene información sobre los cargos de la entidad –llamados **Personas**–, **eventos** de sus agendas, declaraciones de bienes y actividades, obsequios... y su blog.

#### Personas

Las **personas** son todos aquellos cargos de la entidad cuya información se quiere visualizar en el site público. Puedes introducir tantas personas como desees y no hace falta que las hagas públicas inmediatamente. En el site público sólo se visualizarán aquellas a las que asignes el estado de **Publicada**.

Para acceder al listado de personas selecciona **Altos cargos y Agendas** en el menú lateral. Aparecerá una tabla con todas las personas introducidas en el sistema.

Opciones de la tabla de **personas**

- Haz click en el nombre de la persona (la primera columna de la tabla) para [editarla](#cómo_crear_y_editar_una_persona).
- Haz click en **Ver persona** para visualizar el aspecto que tiene su ficha en el sitio público.
- Pincha y arrastra en el icono a la derecha de **Ver persona** para ordenar.

Nota: No confundir las **personas** que aparecen en este módulo con **perfiles de usuarios** o **administradores**. Ejemplo: Un concejal puede tener su perfil de administrador para introducir contenido en el site, pero si quiere introducir sus propias declaraciones de bienes o eventos, deberá crear una **persona** en este módulo.

##### Configuración / Grupos políticos

Selecciona **Configuración**, en la parte superior de la tabla, al lado del botón “Nueva persona” para acceder a las **preferencias** del módulo y al apartado de creación y edición de **grupos políticos**.

- **Preferencias**: Escribe un texto de introducción al módulo de Altos cargos y agendas que aparecerá al principio de la página principal. Por ejemplo: “Conoce a las personas que trabajan para hacer de tu municipio un lugar mejor donde vivir. Consulta sus perfiles, sus agendas, gastos y viajes”.

- **Grupos políticos**: Aquí puedes hacer un listado de todas las agrupaciones que forman parte del pleno de la entidad. Simplemente selecciona **Nueva agrupación** y añade el nombre. Después podrás acceder a los nombres de cada grupo político en los campos de contenido de las personas que lo requieran.


#### Crear y editar una persona

1. Para **crear** una nueva persona, selecciona **Nueva persona** en la parte superior derecha de la tabla de personas. Si quieres **editar** una persona ya creada, pincha en el listado sobre el **nombre** de la persona en cuestión.
1. Introduce la información en los campos correspondientes.
1. Fíjate en los bloques que tienen en el encabezado las opciones de **Editar** y **Eliminar bloque**. Estos son **bloques de contenido personalizables**. Si lo deseas, puedes cambiar los encabezados de la tabla para definir qué tipo de datos estás introduciendo. También puedes crear **nuevos bloques de contenido personalizables** desde cero. Para hacerlo desplázate hasta el final de la página y selecciona **Añadir nuevo bloque**.
1. Selecciona **Borrador** o **Publicado**: Si no quieres que el perfil de esta persona sea público todavía, selecciona **Borrador** en la parte superior derecha de la pantalla. Una vez que hayas creado a la persona podrás ver una previsualización de cómo se vería su perfil públicamente desde el [listado de personas (seleccionando “Ver persona”)](#personas). Si por el contrario quieres hacer públicos los cambios inmediatamente, selecciona **Publicada**.

Cuando hayas introducido todos los datos, selecciona **Crear** o **Actualizar** para hacer efectivos los cambios.

Para seguir editando los datos personales y profesionales o para editar los apartados de **Agenda**, **Declaraciones** y **Blog** vuelve al inicio del módulo de personas y edita tu nueva persona pinchando en su nombre.

Una vez que hayas creado una persona, edítala seleccionando su nombre en el listado de personas. Verás que puedes acceder a las pestañas **Agenda**, **Declaraciones** y **Blog**.

#### Agenda

Cada persona tiene su agenda correspondiente en Gobierto. Los **eventos** se pueden introducir manualmente o pueden aparecer en este módulo de forma automática mediante integraciones con sistemas externos como Google Calendar, Outlook/Exchange o IBM Notes.

##### Crear y/o editar los datos de un evento manualmente

1. Entra en la ficha de una persona, y selecciona la pestaña Agenda.
1. Selecciona **Nuevo evento** o pincha en el **nombre del evento** en la tabla para editarlo.
1. Rellena la información del evento. Por defecto, todos los eventos se marcan como **Pendientes** (en la parte superior derecha de la pantalla) para que no se hagan públicos inmediatamente. Si quieres hacerlo público, selecciona **Publicado** y se publicará cuando apruebes los cambios en el paso siguiente.
1. Dale a **Crear** o **Actualizar** para aprobar todos los cambios.

##### Sincronización de agendas

###### Google Calendar

La integración permite sincronizar Gobierto con la cuenta de Google de la persona cuyo perfil y eventos estaremos mostrando en Gobierto, para que se lean los eventos de uno o varios calendarios de la cuenta de esa persona. Es decir, que la persona puede mantener un calendario privado, y crear otro que sea "Eventos Públicos" y sincronizar solo este calendario.

La integración se ha diseñado para que la persona no tenga que compartir sus credenciales de acceso a su cuenta de Google, y que no sea necesario que la persona tenga un login de Gobierto.

Gobierto tiene en cuenta eventos únicos así como eventos recurrentes.

**Cómo activar la sincronización de eventos**

La forma de enlazar el calendario de Google Calendar de la persona con Gobierto es la siguiente:

- desde la página de Configuración dentro del módulo de Personas se debe seleccionar la opción IBM Notes en el desplegable "Integración de Calendario".

- desde la página de agenda de la persona (a la que accede el administrador de Gobierto), en la opción Configuración, el administrador podrá seleccionar una URL de enlace. Esta URL deberá ser enviada por correo-e a la persona.

- cuando la persona abra la URL, será redirigido a la página de autenticación de Google. En esta página la persona dará permisos a Gobierto para leer la agenda de la persona.

- una vez que se ha dado permiso, la persona podrá seleccionar si quiere sincronizar todos los calendarios de esa cuenta, o solo uno (o varios). Esta selección de calendarios también podrá realizarse después desde la página de Configuración de la Agenda de una persona.

Una vez que se haya realizado esta autorización, Gobierto leerá cada hora los eventos del calendario o calendarios sincronizados.

**Cómo desactivar la sincronización de eventos**

En cualquier momento se puede eliminar la sincronización de eventos. Para hacerlo, desde la página de Configuración de la Agenda de la persona, selecciona la opción **Eliminar configuración de Google Calendar** y pincha en Actualizar.

Al hacerlo, todos los eventos que se hayan importado serán eliminados. Si se desea volver a activar la sincronización, habrá que realizar de nuevo el paso de la autorización de la cuenta.

###### Outlook / Exchange

Viniendo pronto!

###### IBM Notes

La integración permite sincronizar Gobierto con el servicio de trabajo en grupo IBM Notes. Una vez activada la sincronización, aquellos eventos marcados como públicos en el calendario de IBM Notes de la persona aparecerá en Gobierto.

La integración se ha diseñado para que la persona no tenga que compartir sus credenciales de acceso a su cuenta a IBM Notes, y que no sea necesario que la persona tenga un login de Gobierto.

Gobierto tiene en cuenta eventos únicos así como eventos recurrentes.

**Cómo activar la sincronización de eventos**

La forma de enlazar el calendario de IBM Notes de la persona con Gobierto es la siguiente:

- desde la página de Configuración dentro del módulo de Personas se debe seleccionar la opción IBM Notes en el desplegable "Integración de Calendario".

- desde la página de agenda de la persona (a la que accede el administrador de Gobierto), en la opción Configuración, el administrador deberá incluir la URL de calendario de IBM Notes.

Una vez que se ha realizado esta configuración, Gobierto leerá cada hora los eventos del calendario o calendarios sincronizados.

**Cómo desactivar la sincronización de eventos**

En cualquier momento se puede eliminar la sincronización de eventos. Para hacerlo: elimina la URL de calendario en la página de Configuración de la Agenda de la persona. Al hacerlo, todos los eventos que se hayan importado serán eliminados. Si se desea volver a activar la sincronización, habrá que realizar de nuevo el paso de la autorización de la cuenta.


#### Declaraciones

1. Selecciona **Nueva declaración** o pincha en el **Título de la declaración** en la tabla para editarla.
1. Rellena la información de la declaración. Por defecto, todas las declaraciones se marcan como **Borrador** (en la parte superior derecha de la pantalla) para que no se hagan públicas inmediatamente. Si quieres hacerla pública, selecciona **Publicada** y se publicará cuando apruebes los cambios en el paso siguiente.
1. Dale a **Crear** o **Actualizar** para aprobar todos los cambios.

**Bloques de contenido personalizables**: Fíjate en los bloques que tienen en el encabezado las opciones de **Editar** y **Eliminar bloque**. Estos son **bloques de contenido personalizables**. Si lo deseas, puedes cambiar los encabezados de la tabla para definir qué tipo de datos estás introduciendo. También puedes crear **nuevos bloques de contenido personalizables** desde cero. Para hacerlo desplázate hasta el final de la página y selecciona **Añadir nuevo bloque**.

#### Blog

Cómo crear y editar un post de blog:

1. Selecciona **Nuevo post** o pincha en el **Título del post** en la tabla para editarlo.
1. Rellena la información del post. Por defecto, todos los posts se marcan como **Borrador** (en la parte superior derecha de la pantalla) para que no se hagan públicos inmediatamente. Si quieres hacerlo público, selecciona **Publicado** y se publicará cuando apruebes los cambios en el paso siguiente.
1. Dale a **Crear** o **Actualizar** para aprobar todos los cambios.

### Presupuestos
Los datos del módulo de presupuestos se cargan y se visualizan automáticamente.

### Consultas sobre presupuestos
Este módulo permite realizar consultas personalizadas sobre el presupuesto de la entidad a modo de encuesta entre los usuarios. Para poder realizar una consulta los usuarios deben estar registrados y verificados (ver [identificación y verificación del usuario](#identificación_y_verificación_del_usuario)).

#### Cómo crear y editar una consulta

1. Selecciona **Consultas de presupuestos** en el menú lateral.
1. Selecciona **Nueva consulta** en el espacio central.
1. Rellena la información de tu consulta

Una vez creada, vuelve al inicio del módulo de consultas y **edita tu nueva consulta** para definir todos los parámetros en las pestañas **Reporte**, **Consulta** y **Partidas**

##### Reporte

Una vez que haya finalizado la consulta, aquí aparecen los resultados y los datos de participación presentados en una serie de gráficos.

##### Consulta

ToDo

##### Partidas

ToDo

### Observatorio

Los datos del módulo de Observatorio se cargan y se visualizan automáticamente.

### Planes

EL módulo de Planes permite visualizar y explorar el contenido de un plan de mandato (PAM), estratégico, etc. Un plan se organiza en una estructura jerarquica de categorias, y un nodo final de ficha de proyecto. La carga del contenido se realiza actualmente via API. 

A través del administrador se pueden definir los tipos de planes que se van a visualizar, y crear N planes por cada tipo de plan. En la edición de un plan se pueden personalizar determinados campos (nombre, descripción, tipo de plan) y se ofrece un fichero JSON que permite personalizar determinados aspectos sobre la visualizacin del plan:

- Subir imágenes personalizadas por categoría.

  ```
  "level0_options": [
    {
      "slug": "economia-emprenedoria-i-ocupacio",
      "logo": "http://www.madrid.es/assets/images/logo-madrid.png"
    }
    ...
  ```

- Decidir si se quieren visualizar el detalle de los proyectos o no

  ```
  "open_node": false
  ```

- Seleccionar si quieres ver la cabecera de la tabla que presenta el listado de proyectos.

  ```
  "show_table_header": false
  ```

- Definir traducciones en singular y plural para los distintos niveles del plan.

  ```
  "level0": {"one": {"ca": "eix", "es": "eje", "en": "axis"},
           "other": {"ca": "eixos", "es": "ejes", "en": "axes"}}
  ```

- Definir las traducciones para las posibles opciones que tiene un proyecto.

  ```
  "option_keys": {
    "GOALS": {
      "ca": "Metes",
      "es": "Objetivos",
      "en": "Goals"
    }, ...
  ```
- Deshabilitar la numeración automática del primer nivel de categorías del plan:
  ```
  "hide_level0_counters": true
  ```

- Subir CSS personalizados para los colores de las categorías.

  ```
  .gobierto_planification section:not(.level_0).cat_1,
  .gobierto_planification section:not(.level_0).cat_1 .node-list .node-title h3,
  .gobierto_planification section:not(.level_0).cat_1 .node-list .node-title h3 a,
  .gobierto_planification section:not(.level_0).cat_1 .node-breadcrumb,
  .gobierto_planification section:not(.level_0).cat_1 .node-breadcrumb a,
  .gobierto_planification section:not(.level_0).cat_1 .cat--negative .fa,
  .gobierto_planification section:not(.level_0).cat_1 .node-list.cat--negative .node-title .fas {
    color: rgb(123,123,123);
  }
  .gobierto_planification section:not(.level_0).cat_1,
  .gobierto_planification section:not(.level_0).cat_1 .node-breadcrumb .fa,
  .gobierto_planification section:not(.level_0).cat_1 .node-list .node-title .fas {
    background: rgba(123,123,123, 0.1);
  }
  .gobierto_planification section:not(.level_0).cat_1 .cat--negative,
  .gobierto_planification section:not(.level_0).cat_1 .cat--negative h3,
  .gobierto_planification section:not(.level_0).cat_1 .cat--negative h3 a,
  .gobierto_planification section:not(.level_0).cat_1 .node-list.cat--negative .node-title h3,
  .gobierto_planification section:not(.level_0).cat_1 .node-list.cat--negative .node-title h3 a {
    color: white;
  }
  .gobierto_planification section:not(.level_0).cat_1 .cat--negative .fa,
  .gobierto_planification section:not(.level_0).cat_1 .node-list.cat--negative .node-title .fas {
    background: white;
  }
  .gobierto_planification section:not(.level_0).cat_1 .node-breadcrumb {
    border: 1px solid rgba(123,123,123, 0.75);
  }
  .gobierto_planification section:not(.level_0).cat_1 .node-project-detail .project-mandatory,
  .gobierto_planification section:not(.level_0).cat_1 .node-action-line table tbody tr:hover td {
    background-color: rgba(123,123,123, 0.2);
  }
  .gobierto_planification section:not(.level_0).cat_1 .node-project-detail .project-optional .row {
    border-top: 1px solid rgba(123,123,123, 0.2);
  }
  .gobierto_planification section.level_0 .cat_1 {
    background-color: rgba(123,123,123, 0.95);
  }
  .gobierto_planification section.level_0 .cat_1 .progress {
    background-color: rgb(123,123,123);
  }
  .gobierto_planification section:not(.level_0).cat_1 .cat--negative {
    background: rgb(123,123,123);
  }
  ```
- Importar planes completos desde ficheros CSV. Hay una [guía en inglés](docs/gobierto_plans/plan_import_and_configuration.md)
donde se especifican las características del CSV.

## Preguntas frecuentes

ToDo
