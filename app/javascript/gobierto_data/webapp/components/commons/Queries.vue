<template>
  <div class="gobierto-data-summary-queries">
    <h2 class="gobierto-data-tabs-section-title">
      <i class="fas fa-caret-down" />
      {{ labelQueries }}
    </h2>
    <div class="gobierto-data-summary-queries-panel pure-g">
      <div class="pure-u-1-2">
        <div class="gobierto-data-summary-queries-element">
          <i class="fas fa-caret-down" />
          <h3 class="gobierto-data-summary-queries-panel-title">
            {{ labelYourQueries }}
          </h3>
        </div>
        <div class="gobierto-data-summary-queries-element">
          <i class="fas fa-caret-down" />
          <h3 class="gobierto-data-summary-queries-panel-title">
            {{ labelYourQueries }}
          </h3>
        </div>
        <div class="gobierto-data-summary-queries-element">
          <i class="fas fa-caret-down" />
          <h3 class="gobierto-data-summary-queries-panel-title">
            {{ labelYourQueries }}
          </h3>
        </div>
      </div>
      <div class="pure-u-1-2">
        <p class="gobierto-data-summary-queries-sql-code">
          SELECT tipo, nombre
        </p>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  name: "Queries",
  data() {
    return {
      labelQueries: '',
      labelYourQueries: '',
    }
  },
  created() {
    this.labelYourQueries = I18n.t("gobierto_data.projects.yourQueries")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.$root.$on('saveYourQueries', this.listYourQueries)
  },
  methods: {
    listYourQueries(values) {
      const { 0: name, 1: code, 2: privacy } = values
    }
  }
}

</script>
