<template>
  <div class="dashboards-viewer">
    <transition name="fade">
      <!-- show list if there's more than one -->
      <template v-if="isList">
        <div class="dashboards-viewer__card-grid">
          <ListCard
            v-for="{ id: uid, attributes } in dashboards"
            :key="uid"
            v-bind="attributes"
            @click.native="handleClick(uid)"
          />
        </div>
      </template>
      <!-- display directly the dashboard otherwise -->
      <template v-else-if="currentDashboard">
        <Viewer :config="currentDashboard" />
      </template>
    </transition>
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
      currentDashboard: null
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
    isList() {
      return !this.currentDashboard && this.dashboards.length > 1
    }
  },
  async created() {
    if (this.id) {
      const { data } = await this.getDashboard(this.id, { context: this.context, data_pipe: this.pipe })
      this.dashboards.push(data)
      this.currentDashboard = data
    } else {
      ({ data: this.dashboards } = await this.getDashboards({ context: this.context, data_pipe: this.pipe }))
    }
  },
  methods: {
    handleClick(uid) {
      this.currentDashboard = this.dashboards.find(({ id }) => id === uid)
      this.$emit('current-dashboard', this.currentDashboard)
    }
  }
};
</script>
