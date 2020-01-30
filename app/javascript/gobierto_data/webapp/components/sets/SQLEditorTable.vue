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
    <button
      v-show="showTotalRows"
      class="gobierto-data-btn-blue btn-sql-editor btn-sql-show-all"
      @click="queryTotal()"
    >
      Mostrar todas las filas
    </button>
  </div>
</template>
<script>
import axios from 'axios';
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
      mutableList: this.items,
      showTotalRows: false,
      tableName: ''
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
    this.showAllRows()
    this.$root.$on('sendCompleteQuery', this.updateQuery)
    this.tableName = this.$route.params.tableName
  },
  created() {
    this.labelSave = I18n.t('gobierto_data.projects.save');
  },
  methods: {
    updateQuery(code) {
      this.queryEditor = code
    },
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
    },
    showAllRows() {
      if (this.$route.params.rowsDataset > 100) {
        this.showTotalRows = true
      } else {
        this.showTotalRows = false
      }
    },
    queryTotal() {
      this.urlPath = location.origin
      this.endPoint = '/api/v1/data/data';
      if (this.queryEditor === undefined) {
        this.queryEditor =
        this.code = `SELECT * FROM ${this.tableName}`
      }
      this.url = `${this.urlPath}${this.endPoint}?sql=${this.queryEditor}`

      axios
        .get(this.url)
        .then(response => {
          this.data = []
          this.keysData = []
          this.rawData = response.data
          this.meta = this.rawData.meta
          this.data = this.rawData.data

          this.queryDurationRecors = [this.meta.rows, this.meta.duration]

          this.keysData = Object.keys(this.data[0])

          this.$root.$emit('recordsDuration', this.queryDurationRecors)
          this.$root.$emit('sendData', this.keysData, this.data)
          this.$root.$emit('showMessages', true)

        })
        .catch(error => {
          this.$root.$emit('apiError', error)
          this.data = []
          this.keysData = []
          this.$root.$emit('sendData', this.keysData)
        })
    }
  }
}
</script>
