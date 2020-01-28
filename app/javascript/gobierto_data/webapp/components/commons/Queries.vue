<template>
  <div class="gobierto-data-summary-queries">
    <div class="gobierto-data-summary-queries-panel pure-g">
      <div class="pure-u-1-2">
        <div class="gobierto-data-summary-queries-element">
          <h3
            class="gobierto-data-summary-queries-panel-title"
            @click="showYourQueries = !showYourQueries"
          >
            <i
              class="fas fa-caret-down"
              style="color: var(--color-base);"
            />
            {{ labelYourQueries }} ({{ arrayQueries.length }})
          </h3>
          <div
            v-for="(item, index) in arrayQueries"
            v-show="showYourQueries"
            :key="index"
            class="gobierto-data-summary-queries-container"
            @mouseover="showCode(index)"
            @mouseleave="hideCode = true"
            @click="runYourQuery(arrayQueries[index].attributes.sql);sendQuery(item)"
          >
            <span class="gobierto-data-summary-queries-container-name"> {{ item.attributes.name }}</span>

            <div
              v-if="item.attributes.privacy_status === 'closed'"
              class="gobierto-data-summary-queries-container-icon"
            >
              <i
                style="color: #D0021B"
                class="fas fa-lock-close"
              />
            </div>
            <div
              v-else
              class="gobierto-data-summary-queries-container-icon"
            >
              <i
                style="color: rgb(160, 197, 29)"
                class="fas fa-lock-open"
              />
            </div>
            <!-- <div
              v-if="item.attributes.favorites === 'star'"
              class="gobierto-data-summary-queries-container-icon"
            >
              <i
                style="color: #D0021B"
                class="fas fa-lock-close"
              />
            </div>
            <div v-else>
              <i
                style="color: rgb(160, 197, 29)"
                class="fas fa-lock-open"
              />
            </div> -->
          </div>
        </div>
        <div class="gobierto-data-summary-queries-element">
          <h3
            class="gobierto-data-summary-queries-panel-title"
            @click="showYourFavQueries = !showYourFavQueries"
          >
            <i
              class="fas fa-caret-down"
              style="color: var(--color-base);"
            />
            {{ labelFavs }} ({{ numberFavQueries }})
          </h3>
        </div>
        <div class="gobierto-data-summary-queries-element">
          <h3
            class="gobierto-data-summary-queries-panel-title"
            @click="showYourTotalQueries = !showYourTotalQueries"
          >
            <i
              class="fas fa-caret-down"
              style="color: var(--color-base);"
            />
            {{ labelAll }} ({{ arrayQueries.length + numberFavQueries }})
          </h3>
          <div
            v-for="(item, index) in arrayQueries"
            v-show="showYourTotalQueries"
            :key="index"
            class="gobierto-data-summary-queries-container"
            @mouseover="showCode(index)"
            @mouseleave="hideCode = true"
            @click="runYourQuery(arrayQueries[index].attributes.sql);sendQuery(item)"
          >
            <span class="gobierto-data-summary-queries-container-name"> {{ item.attributes.name }}</span>

            <div
              v-if="item.attributes.privacy_status === 'close'"
              class="gobierto-data-summary-queries-container-icon"
            >
              <i
                style="color: #D0021B"
                class="fas fa-lock-close"
              />
            </div>
            <div
              v-else
              class="gobierto-data-summary-queries-container-icon"
            >
              <i
                style="color: rgb(160, 197, 29)"
                class="fas fa-lock-open"
              />
            </div>
          </div>
        </div>
      </div>
      <div class="pure-u-1-2 border-color-queries">
        <p class="gobierto-data-summary-queries-sql-code">
          <span v-if="!hideCode"> {{ sqlCode }}</span>
        </p>
      </div>
    </div>
  </div>
</template>
<script>
import axios from 'axios';
export default {
  name: "Queries",
  props: {
    arrayQueries: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      labelQueries: '',
      labelYourQueries: '',
      labelFavs: '',
      labelAll: '',
      hideCode: true,
      sqlCode: '',
      numberQueries: this.arrayQueries.length,
      numberFavQueries: 0,
      totalQueries: this.arrayQueries.length + this.numberFavQueries,
      showSection: true,
      showYourQueries: true,
      showYourFavQueries: false,
      showYourTotalQueries: false
    }
  },
  created() {
    this.labelYourQueries = I18n.t("gobierto_data.projects.yourQueries")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelFavs = I18n.t("gobierto_data.projects.favs")
    this.labelAll = I18n.t("gobierto_data.projects.all")
  },
  methods: {
    showCode(index) {
      this.hideCode = false
      this.sqlCode = this.arrayQueries[index].attributes.sql
    },
    sendQuery(item) {
      this.queryParams = [item.attributes.name, item.attributes.privacy_status, item.attributes.sql ]
      this.queryCode = item.attributes.sql
      this.$root.$emit('sendQueryParams', this.queryParams)
      this.$root.$emit('sendQueryCode', this.queryCode)
    },
    toggle() {
      this.showSection = !this.showSection
    },
    runYourQuery(code) {
      this.showSpinner = true;
      this.queryEditor = encodeURI(code)
      this.$root.$emit('postRecentQuery', code)
      this.$root.$emit('showMessages', false)
      this.$root.$emit('updateCode', code)

      if (this.queryEditor.includes('LIMIT')) {
        this.queryEditor = this.queryEditor
      } else {
        this.$root.$emit('sendCompleteQuery', this.queryEditor)
        this.code = `SELECT%20*%20FROM%20(${this.queryEditor})%20AS%20data_limited_results%20LIMIT%20100%20OFFSET%200`
        this.queryEditor = this.code
      }
      this.urlPath = location.origin
      this.endPoint = '/api/v1/data/data';
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
          this.$root.$emit('sendQueryCode', this.queryCode)

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
    },
    changeTab(value) {
      const sqlCode = value.attributes.sql
      this.$root.$emit('changeNavTab', sqlCode)
    }
  }
}
</script>
