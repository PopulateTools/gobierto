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
import { GOBIERTO_DASHBOARDS } from "lib/events";
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
    document.removeEventListener(GOBIERTO_DASHBOARDS.LOADED, this.dashboardViewerLoaded)
    document.removeEventListener(GOBIERTO_DASHBOARDS.SELECTED, this.dashboardViewerSelected)
  },
  mounted() {
    // Ask for the dashboard-viewer
    const event = new Event(GOBIERTO_DASHBOARDS.LOAD)
    document.dispatchEvent(event)

    // Add the listeners here, since the dashboard-viewer have to be created first
    document.addEventListener(GOBIERTO_DASHBOARDS.LOADED, this.dashboardViewerLoaded)
    document.addEventListener(GOBIERTO_DASHBOARDS.SELECTED, this.dashboardViewerSelected)
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
