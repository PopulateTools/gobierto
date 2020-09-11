import Vue from "vue";
import VueRouter from "vue-router";

import { getRemoteData } from '../webapp/lib/utils'

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
      const TableFirstLevel = () => import("../webapp/containers/costs/table/TableFirstLevel.vue");
      const TableSecondLevel = () => import("../webapp/containers/costs/table/TableSecondLevel.vue");
      const TableItem = () => import("../webapp/containers/costs/table/TableItem.vue");

      Promise.resolve(getRemoteData(options.costsEndpoint)).then((rawData) => {
        this.setGlobalVariables(rawData)

        const router = new VueRouter({
          mode: "history",
          routes: [
            {
              path: "/dashboards/costes/",
              name: 'Home',
              component: Home,
              children: [
              {
                path: "/dashboards/costes/:year?",
                component: TableFirstLevel,
                name: 'TableFirstLevel'
              },
              {
                path: "/dashboards/costes/:year?/:id?",
                component: TableSecondLevel,
                name: 'TableSecondLevel'
              },
              {
                path: "/dashboards/costes/:year?/:id?/:item?",
                component: TableItem,
                name: 'TableItem'
              }
              ]
            },
          ],
          scrollBehavior(to) {
            let element
            //Get a different position scroll
            if (to.name !== 'TableFirstLevel') {
              element = document.getElementById('gobierto-dashboards-title-detail');
              element.scrollIntoView({ behavior: "smooth" });
            }
          }
        });

        const baseTitle = document.title;
        router.afterEach(to => {
          // Wait 2 ticks
          Vue.nextTick(() =>
            Vue.nextTick(() => {
              let title = baseTitle;
              if (to.name === "TableItem") {
                const { description: itemTitle } = to.params;

                if (itemTitle) {
                  title = `${itemTitle} ${baseTitle}`;
                }
              } else if (to.name === "TableSecondLevel") {
                const { description: itemTitle } = to.params;

                if (itemTitle) {
                  title = `${itemTitle} ${baseTitle}`;
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
    const amountStrings = [ 'cd_bens_i_serveis', 'cd_cost_personal', 'cost_directe' , 'cost_indirecte', 'cost_total', 'costpers', 'costrestadir', 'cost_per_habitant', 'ingressos', 'taxa_o_preu_public', 'cd_serveis_exteriors', 'cd_transferencies', 'cd_equipaments', 'ingres_cost', 'subvencio']

    for (let index = 0; index < rawData.length; index++) {
      let d = rawData[index]

      for (let amounts = 0; amounts < amountStrings.length; amounts++) {
        d[amountStrings[amounts]] = convertStringToNumbers(d[amountStrings[amounts]])
      }

      d.ingressos = nanToZero(d.ingressos)
    }

    //Split data by year
    const data2018 = rawData.filter(items => items.any === '2018').map(items => ({ ...items, year: '2018', population: 126988 }))
    const data2019 = rawData.filter(items => items.any === '2019').map(items => ({ ...items, year: '2019', population: 128265 }))

    const totalData = [...data2018, ...data2019]

    let groupDataByYears = []
    let groupData2018 = []
    let groupData2019 = []

    function groupDataByYear(data, year) {
      //Filter groupData by "sumadatos" :https://github.com/PopulateTools/issues/issues/1097
      let dataFilterSum = data.filter(element => element.sumadatos === '')
      let groupData = [...dataFilterSum.reduce((r, o) => {
        const key = o.agrupacio

        const item = r.get(key) || Object.assign({}, o, {
          cost_directe: 0,
          cost_indirecte: 0,
          cost_total: 0,
          ingressos: 0,
          total: 0,
          totalPerHabitant: 0,
          coverage: 0,
        });

        item.cost_directe += o.cost_directe
        item.cost_indirecte += o.cost_indirecte
        item.cost_total += o.cost_total
        item.ingressos += o.ingressos
        //New item with the sum of values of each agrupacio
        item.total += (o.total || 0) + 1
        item.coverage = (item.ingressos * 100) / item.cost_total
        item.totalPerHabitant = item.cost_total / o.population

        return r.set(key, item);
      }, new Map).values()];
      return groupData = groupData.filter(element => element.agrupacio !== '' && element.year === year)
    }

    groupData2018 = groupDataByYear(data2018, '2018')
    groupData2019 = groupDataByYear(data2019, '2019')

    groupDataByYears = [...groupData2018, ...groupData2019]

    groupDataByYears = groupDataByYears.sort((a, b) => (a.cost_total > b.cost_total) ? -1 : 1)

    this.data = {
      costData: totalData,
      groupData: groupDataByYears
    }
  }

}
