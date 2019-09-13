import App from "../webapp/App.vue";
import Vue from "vue";
Vue.config.productionTip = false;

export class InvestmentsController {
  constructor() {
    this.inRangeClass = "in-range";

    // Mount Vue application
    const entryPoint = document.getElementById("investments-app");
    if (entryPoint) {
      new Vue({ render: h => h(App) }).$mount(entryPoint);
    }
  }
}
