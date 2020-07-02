import Vue from "vue";
import VueRouter from "vue-router";

Vue.use(VueRouter);

const Main = () => import("../Main.vue");
const Home = () => import("../pages/Home.vue");
const Categories = () => import("../pages/Categories.vue");
const Projects = () => import("../pages/Projects.vue");
const Groups = () => import("../pages/Groups.vue");
const TableTerms = () => import("../pages/TableTerms.vue");
const Term = () => import("../pages/Term.vue");

// https://router.vuejs.org/guide/essentials/nested-routes.html
export const router = new VueRouter({
  mode: "history",
  routes: [
    {
      path: "/planes/:slug?/:year?",
      alias: "/",
      component: Main,
      children: [
        {
          path: "/",
          name: "home",
          component: Home
        },
        {
          path: "categoria/:id",
          name: "categories",
          component: Categories
        },
        {
          path: "proyecto/:id",
          name: "projects",
          component: Projects
        },
        {
          path: "tabla/:id",
          component: Groups,
          children: [
            {
              path: "/",
              name: "table",
              component: TableTerms
            },
            {
              path: ":term",
              name: "term",
              component: Term
            },
          ]
        },
      ],
    }
  ]
});
