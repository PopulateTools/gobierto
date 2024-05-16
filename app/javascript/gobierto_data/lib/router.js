import Vue from 'vue';
import VueRouter from 'vue-router';

Vue.use(VueRouter);

// ESBuild does not work properly with dynamic components
import Main from '../webapp/pages/Main.vue';
import Index from '../webapp/components/Index.vue';
import Dataset from '../webapp/components/Dataset.vue';
import Visualizations from '../webapp/pages/Visualizations.vue';
// const Main = () => import('../webapp/pages/Main.vue');
// const Index = () => import('../webapp/components/Index.vue');
// const Dataset = () => import('../webapp/components/Dataset.vue');
// const Visualizations = () => import('../webapp/pages/Visualizations.vue');

export const tabs = ['resumen', 'editor', 'consultas', 'visualizaciones', 'descarga', 'mapa']
export const ROUTE_NAMES = {
  Visualizations: 'Visualizations',
  Index: 'Index',
  Dataset: 'Dataset',
  Query: 'Query',
  Visualization: 'Visualization',
  Map: 'Map',
}

// https://router.vuejs.org/guide/essentials/nested-routes.html
export const router = new VueRouter({
  mode: 'history',
  routes: [
    {
      path: '/datos/v/visualizaciones',
      component: Visualizations,
      name: ROUTE_NAMES.Visualizations
    },
    {
      path: '/datos/',
      alias: "/",
      component: Main,
      children: [
        {
          path: '',
          name: ROUTE_NAMES.Index,
          component: Index
        },
        {
          path: ':id/:tab?',
          component: Dataset,
          name: ROUTE_NAMES.Dataset,
          // send props as a function, default to tab[0], otherwise take the index
          props: ({ params: { tab = tabs[0] } }) => ({
            activeDatasetTab: tabs.indexOf(tab)
          })
        },
        {
          path: ':id/q/:queryId?',
          component: Dataset,
          name: ROUTE_NAMES.Query,
          props: { activeDatasetTab: 1 }
        },
        {
          path: ':id/v/:queryId?',
          component: Dataset,
          name: ROUTE_NAMES.Visualization,
          props: { activeDatasetTab: 3 }
        }
      ]
    }
    ],
    scrollBehavior() {
      const element = document.getElementById('gobierto-datos-app');
      const elementBounding = element.getBoundingClientRect();
      const { y } = elementBounding
      if (window.pageYOffset > (y + window.scrollY)) {
        window.scrollTo({
          top: element.offsetTop,
          behavior: 'smooth'
        });
      }
    }
  });
