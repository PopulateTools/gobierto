import Vue from 'vue';
import VueRouter from 'vue-router';
import { EventBus } from '../webapp/lib/mixins/event_bus';
import { getRemoteData, toNumber } from '../webapp/lib/utils';
import { debtsEvolutionString } from '../webapp/lib/config/debts.js';
import { checkAndReportAccessibility } from '../../lib/vue/accessibility';

// ESBuild does not work properly with dynamic components
import Home from '../webapp/containers/odss/Home.vue';

if (Vue.config.devtools) {
  Vue.use(checkAndReportAccessibility)
}

Vue.use(VueRouter);
Vue.config.productionTip = false;

export class OdssController {
  constructor(options) {
    this.charts = {};

    const selector = "gobierto-visualizations-odss-app";

    // Mount Vue applications
    const entryPoint = document.getElementById(selector);

    if (entryPoint) {
      const htmlRouterBlock = `<router-view></router-view>`;

      entryPoint.innerHTML = htmlRouterBlock;

      Promise.all([
        getRemoteData(options.odssFunctionalBudgetsOdss),
        getRemoteData(options.odssOdssBudgets)
      ]).then(rawData => {
        this.setGlobalVariables(rawData);
        const router = new VueRouter({
          mode: "history",
          routes: [{
            path: "/visualizaciones/ods",
            name: "Home",
            component: Home
          }],
        });

        // Events must listen BEFORE vue application to start (i.e. the trigger)
        EventBus.$on("mounted", () => {
          // Hide the external loader once the vueApp has been mounted in the DOM
          const loadingElement = document.querySelector(".js-loading");
          if (loadingElement) {
            loadingElement.classList.add("hidden");
          }
        });

        const data = Object.assign(options, this.data)

        this.vueApp = new Vue({
          router,
          // data,
          provide: {
            data
          }
        }).$mount(entryPoint);
      });
    }
  }

  parseData(rawData, filter) {
    const data = rawData.map((item) => {
      for (let element of filter) {
        item[element] = item[element].includes('.')
          ? toNumber(item[element].replace(/\./g,'').replace(/,/g,'.'))
          : item[element]
          ? toNumber(item[element].replace(/,/g,'.'))
          : toNumber(item[element])
      }
      return {
        ...item
      }
    })
    return data
  }

  //The keys for the treemap always have the same value,
  //only the year changes, search in the keys of the data
  //the pattern that contains the word 'endeutament'
  getKey(data, string) {
    return Object.keys(data[0]).filter(element => element.includes(string))
  }

  setGlobalVariables(rawData) {
    this.functionalBudgetsOdssKey = this.getKey(rawData[0], 'functional_code')
    this.odssBudgetsKey = this.getKey(rawData[1], 'ods_code')
    this.data = {
      functionalBudgetsOdss: this.parseData(rawData[0], this.functionalBudgetsOdssKey),
      functionalBudgetsOdssKey: this.functionalBudgetsOdssKey,
      odssBudgets: this.parseData(rawData[1], this.odssBudgetsKey),
      odssBudgetsKey: this.odssBudgetsKey
    };
  }
}
