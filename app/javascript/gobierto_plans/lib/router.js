import Vue from "vue";
import VueRouter from "vue-router";

Vue.use(VueRouter);

const Main = () => import("../webapp/Main.vue");
const ByCategory = () => import("../webapp/ByCategory.vue");

// https://router.vuejs.org/guide/essentials/nested-routes.html
export const router = new VueRouter({
  mode: "history",
  routes: [
    {
      path: "/planes/:name/:year",
      component: Main,
      children: [
        {
          path: "/",
          component: ByCategory
        }
      ]
    }
  ]
});
