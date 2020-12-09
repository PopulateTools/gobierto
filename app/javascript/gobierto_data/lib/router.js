import Vue from "vue";
import VueRouter from "vue-router";

Vue.use(VueRouter);

const Main = () => import("../webapp/pages/Main.vue");
const Index = () => import("../webapp/components/Index.vue");
const Dataset = () => import("../webapp/components/Dataset.vue");
const Visualizations = () => import("../webapp/pages/Visualizations.vue");

export const tabs = ['resumen', 'editor', 'consultas', 'visualizaciones', 'descarga']

// https://router.vuejs.org/guide/essentials/nested-routes.html
export const router = new VueRouter({
  mode: 'history',
  routes: [
    {
      path: '/datos/v/visualizaciones',
      component: Visualizations,
      name: 'Visualizations'
    },
    {
      path: '/datos/',
      component: Main,
      children: [
        {
          path: '',
          name:'index',
          component: Index
        },
        {
          path: '/datos/terms/*',
          name:' terms',
          component: Index
        },
        {
          path: ':id/:tab?',
          component: Dataset,
          name: 'Dataset',
          // send props as a function, default to tab[0], otherwise take the index
          props: ({ params: { tab = tabs[0] } }) => ({
            activeDatasetTab: tabs.indexOf(tab)
          })
        },
        {
          path: ':id/q/:queryId?',
          component: Dataset,
          name: 'Query',
          props: { activeDatasetTab: 1 }
        },
        {
          path: ':id/v/:queryId?',
          component: Dataset,
          name: 'Visualization',
          props: { activeDatasetTab: 3 }
        }
      ]
    }
    ],
    scrollBehavior() {
      const element = document.getElementById('gobierto-datos-app');
      window.scrollTo({
        top: element.offsetTop,
        behavior: 'smooth'
      });
    }
  });
