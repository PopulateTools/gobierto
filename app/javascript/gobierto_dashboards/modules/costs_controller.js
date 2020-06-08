import Vue from "vue";
import VueRouter from "vue-router";

import { nest } from 'd3-collection';
import { sum } from 'd3-array';
import { getRemoteData } from '../webapp/lib/utils'

const d3 = { nest, sum }

Vue.use(VueRouter);
Vue.config.productionTip = false;

export class CostsController {
  constructor(options) {
    this.charts = {};

    const selector = "gobierto-dashboards-costs-app";

    // Mount Vue applications
    const entryPoint = document.getElementById(selector);

    if (entryPoint) {
      const htmlRouterBlock = `<router-view></router-view>`;

      entryPoint.innerHTML = htmlRouterBlock;

      const Home = () => import("../webapp/containers/costs/Home.vue");
      const TableSecondLevel = () => import("../webapp/containers/costs/TableSecondLevel.vue");
      const TableItem = () => import("../webapp/containers/costs/TableItem.vue");

      Promise.resolve(getRemoteData(options.costsEndpoint)).then((rawData) => {
        this.setGlobalVariables(rawData)

        const router = new VueRouter({
          mode: "history",
          routes: [
            {
              path: "/dashboards/costes",
              component: Home,
              name: 'Home',
            },
            {
              path: "/dashboards/costes/:id?",
              component: TableSecondLevel,
              name: 'TableSecondLevel'
            },
            {
              path: "/dashboards/costes/:id?/:item?",
              component: TableItem,
              name: 'TableItem'
            }
          ],
          scrollBehavior() {
            const element = document.getElementById(selector);
            window.scrollTo({ top: element.offsetTop, behavior: "smooth" });
          }
        });

        const baseTitle = document.title;
        router.afterEach(to => {
          // Wait 2 ticks
          Vue.nextTick(() =>
            Vue.nextTick(() => {
              let title = baseTitle;

              if (to.name === "costs") {
                const { item: { title: itemTitle } = {} } = to.params;

                if (itemTitle) {
                  title = `${itemTitle}${baseTitle}`;
                }
              }

              document.title = title;
            })
          );
        });

        this.vueApp = new Vue({
          router,
          data: Object.assign(options, this.data)
        }).$mount(entryPoint);

        const loadingElement = document.querySelector(".js-loading");
        if (loadingElement) {
          loadingElement.classList.add('hidden')
        }
      });
    }
  }

  setGlobalVariables(rawData) {

    //Convert strings with some format to Numbers without format
    function convertStringToNumbers(amount) {
      return Number(parseFloat(amount.replace(/\./g,'').replace(',','.')))
    }

    //Some values are empty, so we need to transform to zero
    function nanToZero(val) {
       val = +val || 0
       return val;
    }

    //Array with all the strings that we've to convert to Number
    const amountStrings = [ 'cd_bens_i_serveis', 'cd_cost_personal', 'cost_directe_2018' , 'cost_indirecte_2018', 'cost_total_2018', 'costpers2018', 'costrestadir2018', 'cost_per_habitant', 'ingressos', 'respecte_ambit', 'taxa_o_preu_public', 'cd_serveis_exteriors', 'cd_transferencies', 'cd_equipaments', 'ingres_cost', 'subvencio']

    for (let index = 0; index < rawData.length; index++) {
      let d = rawData[index]

      for (let amounts = 0; amounts < amountStrings.length; amounts++) {
        d[amountStrings[amounts]] = convertStringToNumbers(d[amountStrings[amounts]])
      }

      //Include a year column
      if (d.cost_directe_2018) {
        d['year'] = '2018'
      } else if (d.cost_directe_2019) {
        d['year'] = '2019'
      }

      d.ingressos = nanToZero(d.ingressos)
    }

    let groupData = []
    groupData = [...rawData.reduce((r, o) => {
      const key = o.agrupacio

      const item = r.get(key) || Object.assign({}, o, {
        cost_directe_2018: 0,
        cost_indirecte_2018: 0,
        cost_total_2018: 0,
        ingressos: 0,
        respecte_ambit: 0,
        total: 0
      });

      item.cost_directe_2018 += o.cost_directe_2018
      item.cost_indirecte_2018 += o.cost_indirecte_2018
      item.cost_total_2018 += o.cost_total_2018
      item.ingressos += o.ingressos
      //New item with the sum of values of each agrupacio
      item.total += (o.total || 0) + 1
      item.respecte_ambit += o.respecte_ambit

      return r.set(key, item);
    }, new Map).values()];
    groupData = groupData.filter(element => element.agrupacio !== '')

    this.data = {
      costData: rawData,
      agrupacioData: groupData
    }
  }

}
