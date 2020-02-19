<template>
  <div
    v-if="orderItems"
    class="gobierto-data-sql-editor-recent-queries arrow-top"
  >
    <div class="gobierto-data-btn-download-data-modal-container">
      <button
        v-for="(item, index) in orderItems"
        ref="button"
        :key="index"
        :class="{'active-query': currentItem === index}"
        :data-id="item.text"
        class="gobierto-data-recent-queries-list-element"
        @click="runRecentQuery(item.text)"
      >
        {{ item.text }}
      </button>
    </div>
  </div>
</template>
<script>
import axios from 'axios'
import { baseUrl } from "./../../../lib/commons.js";
export default {
  name: "RecentQueries",
  props: {
    tableName: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      orderItems: null,
      currentItem: 0
    }
  },
  created() {
    this.$root.$on('showRecentQueries', this.createList)
    this.$root.$on('storeQuery', this.createList)
  },
  mounted(){
    document.addEventListener("keyup", this.nextItem);
  },
  methods: {
    nextItem () {
      if (event.keyCode == 38 && this.currentItem > 0) {
        this.currentItem--
      } else if (event.keyCode == 40 && this.currentItem < this.items.length) {
        this.currentItem++
      }
    },
    createList(queries) {
      if (queries === null || queries === undefined) {
        this.orderItems = []
      } else {
        const items = queries
        const filterItemsByDataset = items.filter(item => item.dataset === this.tableName);
        const filterItemsByQuery = filterItemsByDataset.filter(item => item.text.includes(this.tableName));
        this.orderItems = filterItemsByQuery.reverse()
      }
    },
    runRecentQuery(code) {
      this.queryEditor = encodeURI(code)
      this.$root.$emit('postRecentQuery', code)
      this.$root.$emit('showMessages', false, true)
      this.$root.$emit('updateCode', code)

      if (this.queryEditor.includes('LIMIT')) {
        this.queryEditor = this.queryEditor
        this.$root.$emit('hiddeShowButtonColumns')
      } else {
        this.$root.$emit('ShowButtonColumns')
        this.$root.$emit('sendCompleteQuery', this.queryEditor)
        this.code = `SELECT%20*%20FROM%20(${this.queryEditor})%20AS%20data_limited_results%20LIMIT%20100%20OFFSET%200`
        this.queryEditor = this.code
      }

      const endPoint = `${baseUrl}/data`
      const url = `${endPoint}?sql=${this.queryEditor}`
      axios
        .get(url)
        .then(response => {
          let data = []
          let keysData = []
          const rawData = response.data
          const meta = rawData.meta
          data = rawData.data

          const queryDurationRecords = [ meta.rows, meta.duration ]

          keysData = Object.keys(data[0])

          this.$root.$emit('recordsDuration', queryDurationRecords)
          this.$root.$emit('sendData', keysData, data)
          this.$root.$emit('showMessages', true)
          this.$root.$emit('runSpinner')

        })
        .catch(error => {
          const messageError = error.response.data.errors[0].sql
          this.$root.$emit('apiError', messageError)

          const data = []
          const keysData = []
          this.$root.$emit('sendData', keysData, data)
        })
        setTimeout(() => {
          this.showSpinner = false
        }, 300)
    }
  }
}
</script>
