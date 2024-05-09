<template>
  <div class="m_t_2">
    <Loading
      v-if="isLoading"
      :message="labelLoading"
    />
    <div v-show="!isLoading">
      <!-- markup mandatory markup to build the dashboards app -->
      <template v-if="dashboardId === null">
        <div
          dashboard-viewer-app
          :data-context="context"
          :data-pipe="pipe"
        />
      </template>
      <template v-else>
        <div
          dashboard-viewer-app
          :data-context="context"
          :data-pipe="pipe"
          :data-id="dashboardId"
        />
      </template>
    </div>
  </div>
</template>

<script>
import { GOBIERTO_DASHBOARDS } from '../../../lib/events';
import { Loading } from '../../../lib/vue/components';
import { routes } from '../lib/router';

export default {
  name: "DashboardsTab",
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
    },
    pipe() {
      return this.$root?.$data?.pipe
    },
    dashboardId() {
      return this.$route.params?.dashboardId
    }
  },
  mounted() {
    // Ask for the dashboard-viewer
    const event = new Event(GOBIERTO_DASHBOARDS.LOAD)
    document.dispatchEvent(event)

    // Add the listeners here, since the dashboard-viewer have to be created first
    document.addEventListener(GOBIERTO_DASHBOARDS.LOADED, this.dashboardViewerLoaded)
    document.addEventListener(GOBIERTO_DASHBOARDS.SELECTED, this.dashboardViewerSelected)
  },
  destroyed() {
    document.removeEventListener(GOBIERTO_DASHBOARDS.LOADED, this.dashboardViewerLoaded)
    document.removeEventListener(GOBIERTO_DASHBOARDS.SELECTED, this.dashboardViewerSelected)
  },
  methods: {
    dashboardViewerLoaded() {
      this.isLoading = false
    },
    dashboardViewerSelected({ detail }) {
      this.$router.push({ name: routes.DASHBOARDS, params: { ...this.$route.params, dashboardId: detail?.id } })
    },
  }
};
</script>
