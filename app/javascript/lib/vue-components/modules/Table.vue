<template>
  <div
    data-testid="table-component"
    class="gobierto-table"
  >
    <div class="gobierto-table__header">
      <span class="gobierto-table__header-title">Title</span>
      <TableColumnSelector
        data-testid="table-modal"
        :columns="columns"
        @toggle-visibility="toggleVisibility"
      />
    </div>
    <table />
  </div>
</template>
<script>
import TableColumnSelector from "./TableColumnSelector.vue";
export default {
  name: 'Table',
  components: {
    TableColumnSelector
  },
  props: {
    data: {
      type: Array,
      default: () => []
    },
    visibilityColumns: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      columns: [],
      columnsArray: [],
      elementsTable: []
    }
  },
  created() {
    this.getColumns()
  },
  methods: {
    renderTable() {

    },
    getColumns() {
      this.columnsArray = this.data.reduce((s, o) => [...new Set([...s, ...Object.keys(o)])], []);
      this.columns = this.columnsArray.map((column, index) => ({
        name: column,
        visibility: this.visibilityColumns.includes(column),
        id: index
      }))
    },
    toggleVisibility({ id }) {
      this.visibilityColumns.push(this.columnsArray[this.columnsArray.findIndex((x, index) => index === id)])
    }
  }
}

</script>
