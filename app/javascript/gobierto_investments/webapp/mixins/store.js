export const store = {
  state: {
    items: [],
    phases: [],
    filters: [],
    activeFilters: new Map(),
    activeFiltersSelection: new Map()
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
  addActiveFilters(value) {
    this.state.activeFilters = value;
  },
  addActiveFiltersSelection(value) {
    this.state.activeFiltersSelection = value;
  }
};
