import Vue from "vue";

export function accesibilityAxe() {
  if (process.env.NODE_ENV === 'development') {
    const VueAxe = require('vue-axe').default
    Vue.use(VueAxe)
  }
}
