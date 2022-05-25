import Vue from "vue";
import VueRouter from "vue-router";
import { EventBus } from "../webapp/lib/mixins/event_bus";
import { getRemoteData, toNumber } from "../webapp/lib/utils";
import { debtsEntitatStrings, debtsTotalStrings, debtsEvolutionString } from "../webapp/lib/config/debts.js";
import { checkAndReportAccessibility } from "lib/vue/accesibility";

if (Vue.config.devtools) {
  Vue.use(checkAndReportAccessibility)
}
Vue.use(VueRouter);
Vue.config.productionTip = false;

export class DebtsController {
  constructor(options) {
    this.charts = {};

    const selector = "gobierto-visualizations-debts-app";

    // Mount Vue applications
    const entryPoint = document.getElementById(selector);

    if (entryPoint) {
      const htmlRouterBlock = `<router-view></router-view>`;

      entryPoint.innerHTML = htmlRouterBlock;

      const Home = () =>
        import("../webapp/containers/debts/Home.vue");

      Promise.all([
        getRemoteData(options.debtsEndpoint),
        getRemoteData(options.debtsTotalEndpoint),
        getRemoteData(options.debtsEvolutionEndpoint)
      ]).then(rawData => {
        this.setGlobalVariables(rawData);
        const router = new VueRouter({
          mode: "history",
          routes: [{
            path: "/visualizaciones/deuda",
            name: "Home",
            component: Home
          }],
        });

        this.vueApp = new Vue({
          router,
          data: Object.assign(options, this.data)
        }).$mount(entryPoint);

        EventBus.$on("mounted", () => {
          // Hide the external loader once the vueApp has been mounted in the DOM
          const loadingElement = document.querySelector(".js-loading");
          if (loadingElement) {
            loadingElement.classList.add("hidden");
          }
        });
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

  setGlobalVariables(rawData) {
    const debtsEvolutionParse = rawData[2].map(d => {
      const { any, ajuntament, mataro_audiovisual, c_digital_mataro_maresme, consorci_tr_residus, pumsa, grup_tecnocampus, amsa, deute_fcc, porta_laietana, altres_pie_messa, total_endeutament_grup, total_deute_viu, rati_deute_viu } = d
      return {
        any: any,
        Ajuntament: ajuntament,
        "Mataro Audiovisual": mataro_audiovisual,
        "Digitial Mataro Maresme": c_digital_mataro_maresme,
        "Consorci Residus": consorci_tr_residus,
        PUMSA: pumsa,
        "Grup Tecnocampus": grup_tecnocampus,
        AMSA: amsa,
        "Deute FCC": deute_fcc,
        "Porta Laietana": porta_laietana,
        "Altres pie messa": altres_pie_messa,
        "Deute Viu Grup Ajuntament": total_endeutament_grup,
        "Deute Viu Sector Administracions Públiques": total_deute_viu,
        "Rati deute viu %": rati_deute_viu.split("%")[0]
      }
    })

    this.data = {
      debtsEntitat: this.parseData(rawData[0], debtsEntitatStrings),
      debtsTotal: this.parseData(rawData[1], debtsTotalStrings),
      debtsEvolution: this.parseData(debtsEvolutionParse, debtsEvolutionString)
    };
  }
}
