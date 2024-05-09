import Vue from 'vue';
import VueRouter from 'vue-router';

Vue.use(VueRouter);

const Main = () => import('../Main.vue');
const Plan = () => import('../pages/Plan.vue');
const Categories = () => import('../pages/Categories.vue');
const Projects = () => import('../pages/Projects.vue');
const Groups = () => import('../pages/Groups.vue');
const GroupsByTerm = () => import('../pages/GroupsByTerm.vue');
const ProjectsByTerm = () => import('../pages/ProjectsByTerm.vue');
const PlanTab = () => import('../pages/PlanTab.vue');
const DashboardsTab = () => import('../pages/DashboardsTab.vue');

// routes enumeration names
export const routes = {
  PLAN: "plan",
  CATEGORIES: "categories",
  PROJECTS: "projects",
  TABLE: "table",
  TERM: "term",
  DASHBOARDS: "dashboards"
}

// https://router.vuejs.org/guide/essentials/nested-routes.html
export const createRouter = ({ dashboards = false }) => new VueRouter({
  mode: "history",
  routes: [
    {
      path: "/planes/:slug?/:year?",
      alias: "/",
      component: Main,
      children: [
        {
          path: "",
          component: PlanTab,
          children: [
            {
              path: "",
              name: routes.PLAN,
              component: Plan,
              meta: {
                tab: routes.PLAN,
                button: routes.PLAN
              }
            },
            {
              path: "categoria/:id",
              name: routes.CATEGORIES,
              component: Categories,
              meta: {
                tab: routes.PLAN,
                button: routes.PLAN
              }
            },
            {
              path: "proyecto/:id",
              name: routes.PROJECTS,
              component: Projects,
              meta: {
                tab: routes.PLAN,
                button: routes.PLAN
              }
            },
            {
              path: "tabla/:id",
              component: Groups,
              children: [
                {
                  path: "/",
                  name: routes.TABLE,
                  component: GroupsByTerm,
                  meta: {
                    tab: routes.PLAN
                  }
                },
                {
                  path: ":term",
                  name: routes.TERM,
                  component: ProjectsByTerm,
                  meta: {
                    tab: routes.PLAN
                  }
                },
              ]
            }
          ],
        },
        // optional route
        (dashboards && {
          path: "dashboards/:dashboardId?",
          name: routes.DASHBOARDS,
          component: DashboardsTab
        })
      ].filter(Boolean)
    },
  ],
  scrollBehavior(to) {
    // Only do autoscroll on the plan
    if ([routes.PROJECTS, routes.CATEGORIES].includes(to.name)) {
      return {
        selector: ".node-breadcrumb",
        behavior: "smooth",
        offset: {
          y: 16
        }
       }
    }
  },
})
