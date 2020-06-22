import Vue from "vue";
import VueRouter from "vue-router";

Vue.use(VueRouter);

const Main = () => import("../webapp/Main.vue");
const Home = () => import("../webapp/pages/Home.vue");
const Categories = () => import("../webapp/pages/Categories.vue");
const Projects = () => import("../webapp/pages/Projects.vue");

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
        }
      ]
    }
  ]
});
