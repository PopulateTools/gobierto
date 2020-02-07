<template>
  <div
    class="gobierto-data-sql-editor-recent-queries arrow-top"
    tabindex="-1"
  >
    <div class="gobierto-data-btn-download-data-modal-container">
      <button
        v-for="(item, index) in items"
        ref="button"
        :key="index"
        :class="{'active-query': currentItem === index}"
        :data-id="item | replace()"
        class="gobierto-data-recent-queries-list-element"
        @click="runRecentQuery(item)"
      >
        {{ item | replace() }}
      </button>
    </div>
  </div>
</template>
<script>
import axios from 'axios'
import { baseUrl } from "./../../../lib/commons.js";
export default {
  name: "RecentQueries",
  filters: {
    truncate: function (text, length, suffix) {
        return text.substring(0, length) + suffix;
    },
    replace: function(text) {
      return text.replace(/%20/g, ' ').replace(/%/g, ' ');
    }
  },
  data() {
    return {
      items: [],
      currentItem: 0
    }
  },
  created() {
    this.$root.$on('showRecentQueries', this.createList)
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
      this.items = queries
    },
    runRecentQuery(code) {
      this.showSpinner = true;
      this.queryEditor = encodeURI(code)
      this.$root.$emit('postRecentQuery', code)
      this.$root.$emit('showMessages', false)
      this.$root.$emit('updateCode', code)
      this.endPoint = `${baseUrl}/data`
      this.url = `${this.endPoint}?sql=${this.queryEditor}`

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
          const messageError = error.response.data.errors[0].sql
          this.$root.$emit('apiError', messageError)

          this.data = []
          this.keysData = []
          this.$root.$emit('sendData', this.keysData, this.data)
        })

        setTimeout(() => {
          this.showSpinner = false
        }, 300)
    }
  }
}
</script>
