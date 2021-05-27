import Vue from "vue";
import VueRouter from "vue-router";
import { getRemoteData } from "../webapp/lib/utils";
import { EventBus } from "../webapp/mixins/event_bus";
import { checkAndReportAccessibility } from "lib/vue/accesibility";

checkAndReportAccessibility()
Vue.use(VueRouter);
Vue.config.productionTip = false;

export class CostsController {
  constructor(options) {
    this.charts = {};

    const selector = "gobierto-visualizations-costs-app";

    // Mount Vue applications
    const entryPoint = document.getElementById(selector);

    if (entryPoint) {
      const htmlRouterBlock = `<router-view></router-view>`;

      entryPoint.innerHTML = htmlRouterBlock;

      const Home = () =>
        import("../webapp/containers/costs/Home.vue");
      const TableFirstLevel = () =>
        import("../webapp/containers/costs/table/TableFirstLevel.vue");
      const TableSecondLevel = () =>
        import("../webapp/containers/costs/table/TableSecondLevel.vue");
      const TableItem = () =>
        import("../webapp/containers/costs/table/TableItem.vue");

      Promise.resolve(getRemoteData(options.costsEndpoint)).then(rawData => {
        this.setGlobalVariables(rawData);

        const router = new VueRouter({
          mode: "history",
          routes: [
            {
              path: "/visualizaciones/costes/",
              name: "Home",
              component: Home,
              children: [
                {
                  path: "/visualizaciones/costes/:year?",
                  component: TableFirstLevel,
                  name: "TableFirstLevel"
                },
                {
                  path: "/visualizaciones/costes/:year?/:id?",
                  component: TableSecondLevel,
                  name: "TableSecondLevel"
                },
                {
                  path: "/visualizaciones/costes/:year?/:id?/:item?",
                  component: TableItem,
                  name: "TableItem"
                }
              ]
            }
          ],
          scrollBehavior(to) {
            let element;
            //Get a different position scroll
            if (to.name !== "TableFirstLevel") {
              element = document.getElementById(
                "gobierto-visualizations-title-detail"
              );
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

  setGlobalVariables(rawData) {
    //Convert strings with some format to Numbers without format
    function convertStringToNumbers(amount) {
      if (amount === "") {
        return nanToZero(amount);
      } else {
        return Number(parseFloat(amount));
      }
    }

    //Some values are empty, so we need to transform to zero
    function nanToZero(val) {
      val = +val || 0;
      return val;
    }

    //Array with all the strings that we've to convert to Number
    const amountStrings = [
      "costdirecte",
      "costindirecte",
      "costtotal",
      "costperhabit",
      "costpersonal",
      "costrestadir",
      "ingressos",
      "taxapreupub",
      "subvencions",
      "ingressos_cost",
      "costdirectepers",
      "costdirebens",
      "costdirservext",
      "costdirtransf",
      "costdirequip",
      "costdirfin"
    ];

    const population = ["126988"];

    for (let index = 0; index < rawData.length; index++) {
      let d = rawData[index];

      if (d["any_"] === "2019") {
        d["population"] = population[0];
      }

      for (let amounts = 0; amounts < amountStrings.length; amounts++) {
        d[amountStrings[amounts]] = convertStringToNumbers(
          d[amountStrings[amounts]]
        );
      }
    }

    let yearsCosts = [...new Set(rawData.map(item => item.any_))];

    let groupDataByYears = [];

    //Create an array of objects with all years
    for (let index = 0; index < yearsCosts.length; index++) {
      const data = rawData.reduce((acc, item) => {
        if (item.any_ === yearsCosts[index]) {
          acc.push({ ...item, population: population[index] });
        }
        return acc;
      }, []);
      const dataGroup = groupDataByYear(data, yearsCosts[index]);
      groupDataByYears.push(dataGroup);
    }

    function groupDataByYear(data, year) {
      //Filter groupData by "sumadatos": https://github.com/PopulateTools/issues/issues/1097
      let dataFilterSum = data.filter(({ sumadatos }) => sumadatos === "");
      let groupData = [
        ...dataFilterSum
          .reduce((r, o) => {
            const key = o.agrupacio;

            const item =
              r.get(key) ||
              Object.assign({}, o, {
                costdirecte: 0,
                costindirecte: 0,
                costtotal: 0,
                ingressos: 0,
                total: 0,
                totalPerHabitant: 0,
                coverage: 0
              });

            item.costdirecte += o.costdirecte;
            item.costindirecte += o.costindirecte;
            item.costtotal += o.costtotal;
            item.ingressos += o.ingressos;
            //New item with the sum of values of each agrupacio
            item.total += (o.total || 0) + 1;
            item.coverage = (item.ingressos * 100) / item.costtotal;
            item.totalPerHabitant = item.costtotal / o.population;

            return r.set(key, item);
          }, new Map())
          .values()
      ];
      return (groupData = groupData.filter(
        ({ agrupacio, any_ }) => agrupacio !== "" && any_ === year
      ));
    }

    groupDataByYears = groupDataByYears
      .flat()
      .sort(({ costtotal: a }, { costtotal: b }) => (a > b ? -1 : 1));

    this.data = {
      costData: rawData,
      groupData: groupDataByYears,
      yearsCosts: yearsCosts
    };
  }
}
