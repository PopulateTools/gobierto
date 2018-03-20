![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

# Gobierto

## Front-end contributing (EN)

The front-end of the application uses `webpack` to be built, therefore, to collaborate read the following directives:

The javascript code developed is hosted in `/app/javascripts`. There, the webpack entry point (`entry_point`), is inside the `packs` folder. Each file in this folder represents a package, which corresponds to a module (except `vendor.js`, explained later).

Each of these packages only refers to the module they load, and some of common dependencies if necessary. For example, the file `/app/javascripts/packs/admin.js`, just contains:
```js
import 'shared'
import 'admin'
```
Then, for each module, there is a folder at the same level as `packs` with the name of that module. It contains an `index.js` file and a `modules` folder with all the legacy code. Let's see an example:
```
/app/javascripts/
  packs/
    admin.js
    vendor.js
  admin/
    index.js
    modules/
      script1.js
      script2.js
```
The `index.js` file contains just a list of imports from the `modules` folder starting with `init.js`
The development process is the following:

##### If we need a new module
1. A file is created in `packs/new_module.js` minimum with an `import 'new_module'` inside.
2. The folder `/app/javascripts/new_module` is created with an `index.js` file and a `modules` folder
3. The `index.js` includes imports to all the modules files (TODO: can be improved with a glob)
4. `modules` contains the logic that we want

##### If we need an external dependency, without needing to instantiate it
1. After bringing the dependency with `yarn install` inside the file `vendor.js` we add `import 'dependency``
2. If we had to make it global, we would expose here: `import Dependency from 'dependency'; global.dependency = Dependency` (Not recommended)


##### If we need an external dependency, and also instantiate it
1. After bringing the dependency with `yarn install` inside the` shared` module, we will import it into the `index.js`
2. If we had to modify it, or execute something, we would initialize it in the `index.js`
3. If we needed to add a configuration or something more complex, we would add a script in `shared/modules`, and import them in the `index.js`
4. We export the variable in the bottom of the module `export { Dependency }`
5. In the script that we need this dependency, we add an `import { Dependency } from 'shared'`

The objective of this last block is to gather all external dependencies in the same place for future reuse

## Front-end contributing (ES)

La parte front de la aplicación utiliza `webpack` para construirse, por tanto, para colaborar sigue la siguientes directivas:

El código javascript desarrollado se aloja en `/app/javascripts`. Allí el punto de entrada (`entry_point`) que usa webpack, está dentro de la carpeta `packs`. Cada fichero de esta carpeta representa un paquete, que se corresponde con un módulo (a excepción de `vendor.js`, explicado más adelante).

Cada uno de estos paquetes únicamente hace referencia al módulo que cargan, y alguno de dependencias comunes si fuese necesario. Por ejemplo, el fichero `/app/javascripts/packs/admin.js`, simplemente contiene
```js
import 'shared'
import 'admin'
```
Después, por cada módulo, hay una carpeta al mismo nivel que `packs` con el nombre de dicho módulo. Esta contiene un fichero `index.js` y una carpeta `modules` con todo el código legacy. Veamos un ejemplo:
```
/app/javascripts/
  packs/
    admin.js
    vendor.js
  admin/
    index.js
    modules/
      script1.js
      script2.js
```
El fichero `index.js` contiene una mera lista de imports de la carpeta `modules` empezando por `init.js`
El proceso de desarrollo es el siguiente:

##### Si necesitamos un nuevo módulo
1. Se crea una fichero en `packs/nuevo_modulo.js` minimo con un `import 'nuevo_modulo'` dentro de él.
2. Se crea la carpeta `/app/javascripts/nuevo_modulo` con un fichero `index.js` y una carpeta `modules`
3. El `index.js` incluye imports a todos los ficheros de modules (TODO: se puede mejorar con un glob)
4. `modules` contiene la lógica que queramos

##### Si necesitamos una dependencia externa, sin necesidad de instanciarla
1. Tras traernos la dependencia con `yarn install` dentro del fichero `vendor.js` agregamos `import 'dependencia'`
2. Si tuvieramos que hacerla global, la expodríamos aquí así: `import Dependencia from 'dependencia'; global.dependencia = Dependencia` (No recomendado)


##### Si necesitamos una dependencia externa, y además instanciarla
1. Tras traernos la dependencia con `yarn install` dentro del módulo `shared`, la importaremos en el `index.js`
2. Si tuvieramos que modificarla, o ejecutar algo, la inicializaríamos en el `index.js`
3. Si necesitasemos agregar una configuración o algo más complejo, añadiríamos un script en `shared/modules`, y los importaríamos en el `index.js`
4. Exportamos la variable al final del módulo `export { Dependencia }`
5. En el script que necesitemos dicha dependencia, hacemos un `import { Dependecia } from 'shared'`

El objetivo de este último bloque es aunar todas las dependencias externas en un mismo sitio para una reutilización en el futuro