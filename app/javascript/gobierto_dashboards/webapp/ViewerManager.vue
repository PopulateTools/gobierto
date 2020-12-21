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
import { GOBIERTO_DASHBOARDS } from "lib/events"

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

    // Emit to his parent, if any
    this.$emit(GOBIERTO_DASHBOARDS.LOADED, this.dashboards)
    // Otherwise, dispatch a general event (CustomEvent in order to send payload)
    const event = new CustomEvent(GOBIERTO_DASHBOARDS.LOADED, { detail: this.dashboards })
    document.dispatchEvent(event)
  },
  methods: {
    handleClick(uid) {
      this.currentDashboard = this.dashboards.find(({ id }) => id === uid)

      // Emit to his parent, if any
      this.$emit(GOBIERTO_DASHBOARDS.SELECTED, this.currentDashboard)
      // Otherwise, dispatch a general event (CustomEvent in order to send payload)
      const event = new CustomEvent(GOBIERTO_DASHBOARDS.SELECTED, { detail: this.currentDashboard })
      document.dispatchEvent(event)
    }
  }
};
</script>
