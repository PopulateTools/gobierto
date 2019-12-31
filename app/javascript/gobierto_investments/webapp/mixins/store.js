export const store = {
  state: {
    items: [],
    phases: [],
    filters: [],
    defaultFilters: [],
    activeFilters: new Map(),
    currentTab: 0
  },
  addItems(value) {
    this.state.items = value;
  },
  addPhases(value) {
    this.state.phases = value;
  },
  addFilters(value) {
    this.state.filters = value;
  },
  addDefaultFilters(value) {
    this.state.defaultFilters = value;
  },
  addActiveFilters(value) {
    this.state.activeFilters = value;
  },
  addCurrentTab(value) {
    this.state.currentTab = value;
  }
};
