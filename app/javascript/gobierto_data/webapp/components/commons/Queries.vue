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
            @click="sendQuery(item); changeTab()"
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
    changeTab() {
      this.$root.$emit('changeNavTab', 1)
    }
  }
}
</script>
