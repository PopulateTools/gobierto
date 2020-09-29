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
      if (amount === '' || undefined) {
        return nanToZero(amount)
      } else {
        return Number(parseFloat(amount.replace(/\./g,'').replace(',','.')))
      }
    }

    //Some values are empty, so we need to transform to zero
    function nanToZero(val) {
       val = +val || 0
       return val;
    }

    //Array with all the strings that we've to convert to Number
    const amountStrings = [ 'cost_directe', 'cost_indirecte', 'cost_total', 'cost_per_habitant', 'cost_personal', 'costos_resta_directes', 'ingressos', 'taxa_o_preu_public', 'subvencions', 'ingressos_cost', 'cost_directe_personal', 'cost_directe_bens_i_serveis', 'cost_directe_serveis_exteriors', 'cost_directe_transferencies', 'cost_directe_equipaments', 'cost_directe_financer']

    const population = ['126988']

    for (let index = 0; index < rawData.length; index++) {
      let d = rawData[index]

      if (d['any'] === '2019') {
        d['population'] = population[0]
      }

      for (let amounts = 0; amounts < amountStrings.length; amounts++) {
        d[amountStrings[amounts]] = convertStringToNumbers(d[amountStrings[amounts]])
      }
    }

    //Create an array with all years.
    function getYearsFromData(arr, key) {
      return [...new Map(arr.map(item => [item[key], item])).values()]
    }

    let yearsCosts = getYearsFromData(rawData, 'any')

    yearsCosts = yearsCosts.map(a => a.any);

    let groupDataByYears = []

    //Create an array of objects with all years
    for (let index = 0; index < yearsCosts.length; index++) {
      const data = rawData.filter(items => items.any == yearsCosts[index]).map(items => ({ ...items, population: population[index] }))
      const dataGroup = groupDataByYear(data, yearsCosts[index])
      groupDataByYears.push(dataGroup)
    }

    function groupDataByYear(data, year) {
      //Filter groupData by "sumadatos": https://github.com/PopulateTools/issues/issues/1097
      let dataFilterSum = data.filter(element => element.suma_datos === '')
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
      return groupData = groupData.filter(element => element.agrupacio !== '' && element.any === year)
    }

    groupDataByYears = groupDataByYears.flat().sort((a, b) => (a.cost_total > b.cost_total) ? -1 : 1);

    this.data = {
      costData: rawData,
      groupData: groupDataByYears,
      yearsCosts: yearsCosts
    }
  }

}
