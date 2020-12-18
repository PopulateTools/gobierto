<template>
  <div class="m_t_2">
    <Loading
      v-if="isLoading"
      :message="labelLoading"
    />
    <div v-show="!isLoading">
      <!-- markup mandatory markup to build the dashboards app -->
      <div
        dashboard-viewer-app
        :data-context="context"
      />
    </div>
  </div>
</template>

<script>
import { GobiertoEvents } from "lib/shared";
import { Loading } from "lib/vue-components";

export default {
  name: "Dashboards",
  components: {
    Loading
  },
  data() {
    return {
      isLoading: true,
      labelLoading: I18n.t("gobierto_plans.plan_types.show.loading") || "",
    }
  },
  computed: {
    context() {
      return this.$root?.$data?.context
    }
  },
  destroyed() {
    document.removeEventListener(GobiertoEvents.DASHBOARD_LOADED, this.dashboardViewerLoaded)
    document.removeEventListener(GobiertoEvents.DASHBOARD_SELECTED, this.dashboardViewerSelected)
  },
  mounted() {
    // Ask for the dashboard-viewer
    const event = new Event(GobiertoEvents.LOAD_DASHBOARD_EVENT)
    document.dispatchEvent(event)

    // Add the listeners here, since the dashboard-viewer have to be created first
    document.addEventListener(GobiertoEvents.DASHBOARD_LOADED, this.dashboardViewerLoaded)
    document.addEventListener(GobiertoEvents.DASHBOARD_SELECTED, this.dashboardViewerSelected)
  },
  methods: {
    dashboardViewerLoaded({ detail }) {
      this.isLoading = false
      // if (detail)
      // TODO: count number
    },
    dashboardViewerSelected({ detail }) {
      if (detail) {
        this.$router.push({ name: "dashboards", params: { ...this.$route.params, dashboardid: detail.id } })
      }
    },
  }
};
</script>
