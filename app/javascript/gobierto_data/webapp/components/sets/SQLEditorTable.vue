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
      {{ labelButtonRows }}
    </button>
  </div>
</template>
<script>
import { baseUrl } from "./../../../lib/commons.js";
import axios from 'axios';
export default {
  name: 'SQLEditorTable',
  props: {
    items: {
      type: Array,
      default: () => {
        return []
      }
    },
    numberRows: {
      type: Number,
      required: true
    },
    tableName: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      keysData: [],
      mutableList: this.items,
      showTotalRows: false,
      labelButtonRows: ''
    }
  },
  watch:{
    items: function(newValue){
      this.mutableList = JSON.parse(newValue);
    }
  },
  mounted() {
    this.$root.$on('sendData', this.destroyTable)
    this.keysData = Object.keys(this.mutableList[0])
    this.showAllRows()
    this.$root.$on('sendCompleteQuery', this.updateQuery)
    this.$root.$on('hiddeShowButtonColumns', this.hideButton)
    this.$root.$on('ShowButtonColumns', this.showButton)
  },
  created() {
    this.labelButtonRows = I18n.t('gobierto_data.projects.showRows');
  },
  methods: {
    hideButton() {
      this.showTotalRows = false
    },
    showButton() {
      this.showTotalRows = true
    },
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
      if (this.numberRows > 100) {
        this.showTotalRows = true
      } else {
        this.showTotalRows = false
      }
    },
    queryTotal() {
      this.showTotalRows = false
      const endPoint = `${baseUrl}/data`
      const url = `${endPoint}?sql=${this.queryEditor}`
      if (this.queryEditor === undefined) {
        this.queryEditor = `SELECT * FROM ${this.tableName}`
      }

      axios
        .get(url)
        .then(response => {
          let data = []
          let keysData = []
          const rawData = response.data
          const meta = rawData.meta
          data = rawData.data

          const queryDurationRecords = [ meta.rows, meta.duration ]

          keysData = Object.keys(this.data[0])

          this.$root.$emit('recordsDuration', queryDurationRecords)
          this.$root.$emit('sendData', keysData, data)
          this.$root.$emit('showMessages', true)

        })
        .catch(error => {
          this.$root.$emit('apiError', error)
          const keysData = []
          this.$root.$emit('sendData', keysData)
        })
    }
  }
}
</script>
