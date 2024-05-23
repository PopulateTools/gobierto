import { EventBus } from './event_bus';

export const SharedMixin = {
  created() {
    this.items = this.buildItems();
  },
  mounted() {
    EventBus.$on("refresh-summary-data", () => this.refreshSummaryData());
    EventBus.$emit("summary-ready");
    EventBus.$on("filtered-items-grouped", (data, value = "") =>
      this.updateItems(data, value)
    );
  },
  beforeDestroy() {
    EventBus.$off("refresh-summary-data");
  },
  methods: {
    updateItems(data, value) {
      this.value = value;
      this.visualizationsData = data;
      this.items = this.buildItems();
    }
  }
};
