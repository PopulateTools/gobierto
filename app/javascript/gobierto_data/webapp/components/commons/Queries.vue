<template>
  <div class="gobierto-data-summary-queries">
    <!-- <h2 class="gobierto-data-tabs-section-title">
      <i class="fas fa-caret-down" />
      {{ labelQueries }}
    </h2> -->
    <div class="gobierto-data-summary-queries-panel pure-g">
      <div class="pure-u-1-2">
        <div class="gobierto-data-summary-queries-element">
          <h3 @click="toggle = !toggle" class="gobierto-data-summary-queries-panel-title">
            <i
              class="fas fa-caret-down"
              style="color: var(--color-base);"
            />
            {{ labelYourQueries }} ({{ numberQueries }})
          </h3>
          <div
            v-for="(item, index) in items"
            v-show="toggle"
            :key="index"
            class="gobierto-data-summary-queries-container"
            @mouseover="showCode(index)"
            @mouseleave="hideCode = true"
            @click="sendQuery(item)"
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
          <h3 class="gobierto-data-summary-queries-panel-title">
            <i
              class="fas fa-caret-down"
              style="color: var(--color-base);"
            />
            {{ labelFavs }} ({{ numberFavQueries }})
          </h3>
        </div>
        <div class="gobierto-data-summary-queries-element">
          <h3 class="gobierto-data-summary-queries-panel-title">
            <i
              class="fas fa-caret-down"
              style="color: var(--color-base);"
            />
            {{ labelAll }} ({{ totalQueries }})
          </h3>
          <div
            v-for="(item, index) in items"
            v-show="toggle"
            :key="index"
            class="gobierto-data-summary-queries-container"
            @mouseover="showCode(index)"
            @mouseleave="hideCode = true"
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
  data() {
    return {
      labelQueries: '',
      labelYourQueries: '',
      labelFavs: '',
      labelAll: '',
      items: null,
      hideCode: true,
      sqlCode: '',
      numberQueries: '',
      numberFavQueries: '',
      totalQueries: ''
    }
  },
  created() {
    this.labelYourQueries = I18n.t("gobierto_data.projects.yourQueries")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelFavs = I18n.t("gobierto_data.projects.favs")
    this.labelAll = I18n.t("gobierto_data.projects.all")

    this.$root.$on('listYourQueries', this.listYourQueries)

  },
  mounted() {
    this.listYourQueries()
  },
  methods: {
    listYourQueries() {
      this.urlPath = location.origin
      this.endPoint = '/api/v1/data/queries'
      this.url = `${this.urlPath}${this.endPoint}`
      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data
          console.log("this.rawData", this.rawData);
          this.items = this.rawData.data
          console.log("this.items", this.items);
          this.numberQueries = this.items.length
          this.numberFavQueries = 0
          this.totalQueries = this.items.length + this.numberFavQueries
        })
        .catch(error => {
          const messageError = error.response
        })
    },
    showCode(index) {
      this.hideCode = false
      this.sqlCode = this.items[index].attributes.sql
    },
    sendQuery(item) {
      this.queryParams = [item.attributes.name, item.attributes.privacy_status ]
      this.queryCode = item.attributes.sql
      this.$root.$emit('sendQueryParams', this.queryParams)
      this.$root.$emit('sendQueryCode', this.queryCode)
    }
  }
}

</script>
