export default class Class {
  static extend(prop) {
    // Este es el proto de la clase de la que se extiende
    // (es decir, el padre)
    const _super = this.prototype;

    // Hacemos el truco del constructor vació para mantener
    // la cadena de prototipos pero sin ejecutar el constructor
    // del padre innecesariamente!
    function F() {}
    F.prototype = _super;
    const proto = new F();

    // recorremos el objeto que nos han pasado como parámetro...
    for (const name in prop) {
      // Comprobar que existe el super-método
      // si no existe, no tiene sentido inyectar nada!
      if (typeof prop[name] == "function" &&
        typeof _super[name] == "function") {
        // Se envuelve en una función inmediata para
        // clausurar el valor de name y fn
        proto[name] = (((name, fn) => function() {
          // guardamos lo que tuviera _super...
          const tmp = this._super;
          // this._super = supermetodo (en proto del padre)
          this._super = _super[name];
          // aplicamos el método decorado (guardamos el retorno)
          const ret = fn.apply(this, arguments);
          // se restaura el valor que tenía this._super
          this._super = tmp;
          // devolvemos lo que haya devuelto el metodo decorado
          return ret;
        }))(name, prop[name]);
      } else {
        // Si no hay supermetodo o no es una función,
        // nos limitamos a copiar la propiedad
        proto[name] = prop[name];
      }
    }

    function Klass() {
      // Si existe this.init, lo llamamos al construir
      // una nueva instancia
      if (this.init && typeof this.init == "function") {
        return this.init(...arguments);
      }
    }

    Klass.prototype = proto;
    // Ponemos a mano el nuevo valor del constructor
    Klass.prototype.constructor = Klass;

    // Para que se pueda heredar de las clases generadas,
    // copiamos la función .extend
    Klass.extend = this.extend;

    // Devolvemos la nueva clase
    return Klass;
  }
}