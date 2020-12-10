<template>
  <div class="dashboards-viewer">
    <!-- show list if there's more than one -->
    <template v-if="dashboards.length > 1">
      <div class="dashboards-viewer__card-grid">
        <ListCard
          v-for="{ id: uid, attributes } in dashboards"
          :key="uid"
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
  name: "ViewerManager",
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
  computed: {
    id() {
      return this.$root.$data?.id;
    },
    pipe() {
      return this.$root.$data?.pipe;
    },
    context() {
      return this.$root.$data?.context;
    },
  },
  async created() {
    if (this.id) {
      const { data } = await this.getDashboard(this.id, { context: this.context, data_pipe: this.pipe })
      this.dashboards.push(data)
    } else {
      ({ data: this.dashboards } = await this.getDashboards({ context: this.context, data_pipe: this.pipe }))
    }
  }
};
</script>
