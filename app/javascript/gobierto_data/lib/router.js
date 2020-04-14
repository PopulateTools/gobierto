import Vue from "vue";
import VueRouter from "vue-router";

Vue.use(VueRouter);

const Main = () => import("../webapp/pages/Main.vue");
const Index = () => import("../webapp/components/Index.vue");
const Dataset = () => import("../webapp/components/Dataset.vue");

export const tabs = ['resumen', 'editor', 'consultas', 'visualizaciones', 'descarga']

// https://router.vuejs.org/guide/essentials/nested-routes.html
export const router = new VueRouter({
  mode: "history",
  routes: [{
      path: "/datos",
      component: Main,
      children: [{
        path: "",
        component: Index,
        props: { activeSidebarTab: 0 }
      }, {
        path: ":id/:tab?",
        component: Dataset,
        // send props as a function, default to tab[0], otherwise take the index
        props: ({ params: { tab = tabs[0] } }) => ({ activeDatasetTab: tabs.indexOf(tab), activeSidebarTab: 1 })
      }, {
        path: ":id/q/:queryId?",
        component: Dataset,
        // active the editor for queries
        props: { activeDatasetTab: 1, activeSidebarTab: 1 }
      }]
    }]
})

const baseTitle = document.title;

router.afterEach(to => {
  // Wait 2 ticks
  Vue.nextTick(() =>
    Vue.nextTick(() => {
      let title = baseTitle;
      // FIXME: this is not working because routes don't have a name now
      if (to.name === "dataset") {
        const { titleDataset: dataset } = to.params;

        if (dataset) {
          const titleI18n = dataset
            ? `${dataset} · `
            : "";

          title = `${titleI18n}${baseTitle}`;
        }
      }

      document.title = title;
    })
  );
})
