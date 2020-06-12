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
              if (to.name === "TableFirstLevel" || to.name === "TableSecondLevel" || to.name === "TableItem") {
                const { item: itemTitle} = to.params;

                if (itemTitle) {
                  title = `${baseTitle} ${itemTitle}`;
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
    const amountStrings = [ 'cd_bens_i_serveis', 'cd_cost_personal', 'cost_directe_2018' , 'cost_indirecte_2018', 'cost_total_2018', 'costpers2018', 'costrestadir2018', 'cost_per_habitant', 'ingressos', 'taxa_o_preu_public', 'cd_serveis_exteriors', 'cd_transferencies', 'cd_equipaments', 'ingres_cost', 'subvencio']

    for (let index = 0; index < rawData.length; index++) {
      let d = rawData[index]

      for (let amounts = 0; amounts < amountStrings.length; amounts++) {
        d[amountStrings[amounts]] = convertStringToNumbers(d[amountStrings[amounts]])
      }

      d.ingressos = nanToZero(d.ingressos)
    }

    //Function to replace those keys that contain 2018
    const replacedKeys = rawData.map(({ cost_directe_2018: cost_directe, cost_indirecte_2018: cost_indirecte, cost_total_2018: cost_total, costpers2018: costpers, costrestadir2018: costrestadir, ...items }) => Object.assign({}, items, { cost_directe, cost_indirecte, cost_total, costpers, costrestadir }));

    //This is temporary, until we've the data from 2019
    let duplicate2018_TEMP = [...replacedKeys]
    let duplicate2019_TEMP = [...replacedKeys]

    duplicate2018_TEMP = duplicate2018_TEMP.map(items => ({ ...items, year: '2018', population: 126988 }))
    duplicate2019_TEMP = duplicate2019_TEMP.map(items => ({ ...items, year: '2019', population: 128265 }))

    const totalData = [...duplicate2018_TEMP, ...duplicate2019_TEMP]

    let groupDataByYears = []
    let groupData2018 = []
    let groupData2019 = []

    function groupDataByYear(data, year) {
      let groupData = [...data.reduce((r, o) => {
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

    groupData2018 = groupDataByYear(duplicate2018_TEMP, '2018')
    groupData2019 = groupDataByYear(duplicate2019_TEMP, '2019')

    groupDataByYears = [...groupData2018, ...groupData2019]

    groupDataByYears = groupDataByYears.sort((a, b) => (a.cost_total > b.cost_total) ? -1 : 1)

    this.data = {
      costData: totalData,
      groupData: groupDataByYears
    }
  }

}
