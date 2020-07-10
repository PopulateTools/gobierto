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
      const [name, order] = this.map.get(id);
      this.currentSortColumn = id;
      // toggle sort order
      this.currentSort = order === "up" ? "down" : "up";
      // update the order for the item clicked
      this.map.set(id, [name, this.currentSort]);
    },
    getSorting(column) {
      // ignore the first item of the tuple
      const [, order] = this.map.get(column);
      return order;
    },
  }
};
