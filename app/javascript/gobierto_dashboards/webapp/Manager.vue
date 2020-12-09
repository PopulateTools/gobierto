<template>
  <div class="dashboards-viewer">
    <!-- show list if there's more than one -->
    <template v-if="dashboards.length > 1">
      <div class="dashboards-viewer__card-grid">
        <ListCard
          v-for="{ id, attributes } in dashboards"
          :key="id"
          v-bind="attributes"
        />
      </div>
    </template>
    <!-- display directly the dashboard otherwise -->
    <template v-else-if="dashboards.length === 1">
      <Viewer :config="dashboards[0]" />
    </template>
  </div>
</template>

<script>
import Viewer from "./Viewer";
import ListCard from "./components/ListCard";
import { FactoryMixin } from "./lib/factories";

export default {
  name: "Manager",
  components: {
    Viewer,
    ListCard
  },
  mixins: [FactoryMixin],
  data() {
    return {
      dashboards: [],
    }
  },
  async created() {
    ({ data: this.dashboards } = await this.getDashboards())
  }
};
</script>
