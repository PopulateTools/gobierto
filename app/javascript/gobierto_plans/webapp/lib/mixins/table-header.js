export const TableHeaderMixin = {
  data() {
    return {
      map: new Map(),
      currentSortColumn: "name",
      currentSort: "up",
    };
  },
  methods: {
    handleTableHeaderClick(id) {
      const { sort } = this.map.get(id);
      this.currentSortColumn = id;
      // toggle sort order
      this.currentSort = sort === "up" ? "down" : "up";
      // update the order for the item clicked
      this.map.set(id, { ...this.map.get(id), sort: this.currentSort });
    },
    getSorting(column) {
      // ignore the first item of the tuple
      const { sort } = this.map.get(column)
      return sort;
    },
  }
};
