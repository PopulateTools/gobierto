<template>
  <div class="dashboards-viewer">
    <!-- show list if there's more than one -->
    <template v-if="dashboards.length > 1">
      <div class="dashboards-viewer__card-grid">
        <div
          v-for="{ id, attributes: { title }} in dashboards"
          :key="id"
          class="dashboards-viewer__card"
        >
          <h2 class="dashboards-viewer__card-title">
            {{ title }}
          </h2>
          <span class="dashboards-viewer__card-subtitle">{{ indicatorsLabel }}</span>
        </div>
      </div>
    </template>
    <!-- display directly the dashboard otherwise -->
    <template v-else-if="dashboards.length === 1">
      <Viewer :config="dashboards[0]" />
    </template>
  </div>
</template>

<script>
// add the styles here, because this element can be inserted both as a component or standalone
import "../../../assets/stylesheets/module-dashboards-viewer.scss";
import Viewer from "./Viewer";
import { FactoryMixin } from "./lib/factories";

export default {
  name: "Manager",
  components: {
    Viewer
  },
  mixins: [FactoryMixin],
  data() {
    return {
      dashboards: [],
      indicators: 0
    }
  },
  computed: {
    indicatorsLabel() {
      return I18n.t("gobierto_dashboards.indicators_amount", { amount: this.indicators })
    }
  },
  async created() {
    ({ data: this.dashboards } = await this.getDashboards())
  }
};
</script>
