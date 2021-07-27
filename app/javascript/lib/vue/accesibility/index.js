import Vue from "vue";
import "../../../../assets/stylesheets/accessibility.css";

export function checkAndReportAccessibility() {
  if (process.env.NODE_ENV === 'development') {
    const VueAxe = require('vue-axe').default
    Vue.use(VueAxe, {
      allowConsoleClears: false
    })
  }
}
