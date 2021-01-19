<template>
  <div
    data-testid="table-component"
    class="gobierto-table"
  >
    <div class="gobierto-table__header">
      <span class="gobierto-table__header-title">Title</span>
      <button
        data-testid="table-button-modal"
        class="gobierto-table__header-button"
        @click="toggleModal"
      />
      <TableColumnSelector
        v-show="showModal"
        data-testid="table-modal"
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
    }
  },
  data() {
    return {
      showModal: false
    }
  },
  created() {
    this.getColumns()
  },
  methods: {
    toggleModal() {
      this.showModal = true
    },
    getColumns() {

    }
  }
}

</script>
