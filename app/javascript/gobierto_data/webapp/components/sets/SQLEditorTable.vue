<template>
  <div class="gobierto-data-sql-editor-table-container">
    <table class="gobierto-data-sql-editor-table">
      <thead>
        <tr>
          <th
            v-for="(column, index) in keysData"
            :key="index"
            :item="column"
            class="gobierto-data-sql-editor-table-header"
          >
            {{ column }}
          </th>
        </tr>
      </thead>
      <tbody
        class="gobierto-data-sql-editor-table-body"
      >
        <tr
          v-for="(row, idx) of mutableList"
          :key="idx"
        >
          <td
            v-for="(column, idx1) of keysData"
            :key="idx1"
          >
            {{ row[column] }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>
export default {
  name: 'SQLEditorTable',
  props: {
    items: {
      type: Array,
      default: () => {
        return []
      }
    }
  },
  data() {
    return {
      keysData: [],
      mutableList: this.items
    }
  },
  watch:{
    items: function(){
        this.mutableList = JSON.parse(this.items);
    }
  },
  mounted() {
    this.$root.$on('sendData', this.destroyTable)
    this.keysData = Object.keys(this.mutableList[0])
  },
  created() {
    this.labelSave = I18n.t('gobierto_data.projects.save');
  },
  methods: {
    destroyTable(keys, data) {
      this.keysData = []
      this.data = []
      setTimeout(() => {
        this.showTable(keys, data)
      }, 10)
    },
    showTable(keys, data) {
      this.keysData = keys
      this.mutableList = data
    }
  }
}
</script>
