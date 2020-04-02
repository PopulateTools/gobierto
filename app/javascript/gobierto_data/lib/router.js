import Vue from "vue";
import VueRouter from "vue-router";

Vue.use(VueRouter);

const Home = () => import("../webapp/pages/Home.vue");

export const tabs = ['resumen', 'editor', 'consultas', 'visualizaciones', 'descarga']

export const router = new VueRouter({
  mode: "history",
  routes: [{
      path: "/datos",
      name: "home",
      component: Home,
      props: {
        currentComponent: 'InfoList',
        activateTabSidebar: 0
      }
    },
    {
      path: "/datos/:id",
      name: "dataset",
      component: Home,
      props: {
        currentComponent: 'DataSets',
        activateTabSidebar: 1
      }
    },
    {
      path: `/datos/:id/${tabs[0]}`,
      name: tabs[0],
      component: Home,
      props: {
        currentComponent: 'DataSets',
        activateTabSidebar: 1,
        activeDatasetTabProp: 0
      }
    },
    {
      path: `/datos/:id/${tabs[1]}`,
      name: tabs[1],
      component: Home,
      props: {
        currentComponent: 'DataSets',
        activateTabSidebar: 1,
        activeDatasetTabProp: 1
      }
    },
    {
      path: `/datos/:id/${tabs[2]}`,
      name: tabs[2],
      component: Home,
      props: {
        currentComponent: 'DataSets',
        activateTabSidebar: 1,
        activeDatasetTabProp: 2
      }
    },
    {
      path: `/datos/:id/${tabs[3]}`,
      name: tabs[3],
      component: Home,
      props: {
        currentComponent: 'DataSets',
        activateTabSidebar: 1,
        activeDatasetTabProp: 3
      }
    },
    {
      path: `/datos/:id/${tabs[4]}`,
      name: tabs[4],
      component: Home,
      props: {
        currentComponent: 'DataSets',
        activateTabSidebar: 1,
        activeDatasetTabProp: 4
      }
    },
    {
      path: "/datos/:id/q/:queryId?",
      name: "queries",
      component: Home,
      props: {
        currentComponent: 'DataSets',
        activateTabSidebar: 1,
        activeDatasetTabProp: 2
      }
    }
  ]
})

const baseTitle = document.title;

router.afterEach(to => {
  // Wait 2 ticks
  Vue.nextTick(() =>
    Vue.nextTick(() => {
      let title = baseTitle;
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