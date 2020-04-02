import Vue from "vue";
import { router } from "../lib/router";
import 'codemirror/lib/codemirror.css'

Vue.config.productionTip = false;

export class GobiertoDataController {
  constructor(options) {
    const selector = "gobierto-datos-app";

    // Mount Vue application
    const entryPoint = document.getElementById(selector);
    if (entryPoint) {
      const htmlRouterBlock = `
      <keep-alive>
        <router-view :key="$route.params.id"></router-view>
      </keep-alive>
      `;

      entryPoint.innerHTML = htmlRouterBlock;

      new Vue({
        router,
        data: options,
      }).$mount(entryPoint);
    }
  }
}
