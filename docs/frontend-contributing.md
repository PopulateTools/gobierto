![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

# Gobierto

## Front-end contributing

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
1. Se crea una fichero en `packs/nuevo_modulo.js` minimo con un `import 'nuevo_modulo'` dentor de él.
2. Se crea la carpeta `/app/javascripts/nuevo_modulo` con un fichero `index.js` y una carpeta `modules`
3. El `index.js` incluye imports a todos los fichero de modules (TODO: se puede mejorar con un glob)
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