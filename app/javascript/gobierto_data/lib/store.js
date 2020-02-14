export const store = {
  state: {
    items: [],
    filters: [],
    datasets: [],
    defaultFilters: [],
    activeFilters: new Map()
  },
  addItems(value) {
    this.state.items = value;
  },
  addDatasets(value) {
    this.state.datasets = value;
  },
  addFilters(value) {
    this.state.filters = value;
  },
  addDefaultFilters(value) {
    this.state.defaultFilters = value;
  },
  addActiveFilters(value) {
    this.state.activeFilters = value;
  }
}
