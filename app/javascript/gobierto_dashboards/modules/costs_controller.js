import Vue from "vue";
import VueRouter from "vue-router";

import { EventBus } from '../webapp/mixins/event_bus'

/*import { VisBubble } from "lib/visualizations";*/

Vue.use(VueRouter);
Vue.config.productionTip = false;


//TO-DO: create a factory to get data
let initObject = { method: 'GET' };

function checkStatus(response) {
  if (response.status >= 200 && response.status < 400) {
    return Promise.resolve(response)
  } else {
    return Promise.reject(new Error(response.statusText))
  }
}

const userRequest = new Request('https://mataro.gobify.net/api/v1/data/data?sql=select%20*%20from%20costes', initObject);

async function getData() {
  let response = await fetch(userRequest);
  let dataRequest = await checkStatus(response);
  let data = dataRequest.json()
  return data;
}

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

      Promise.all([getData()]).then((rawData) => {
        const data = rawData

        const router = new VueRouter({
          mode: "history",
          routes: [
            { path: "/costes", component: Home
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
          //TO-DO: factory
          data: Object.assign(options, this.data),
        }).$mount(entryPoint);

        const loadingElement = document.querySelector(".js-loading");
        if (loadingElement) {
          loadingElement.classList.add('hidden')
        }
      });
    }
  }

}
