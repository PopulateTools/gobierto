<template>
  <div>
    <div class="pure-u-1-2 gobierto-data-summary-header">
      <div class="gobierto-data-summary-header-container">
        <i class="fas fa-clock" />
        <span class="gobierto-data-summary-header-container-label">
          {{ labelUpdated }}
        </span>
        <span class="gobierto-data-summary-header-container-text">
          12 oct 2019
        </span>
      </div>
      <div class="gobierto-data-summary-header-container">
        <i class="fas fa-calendar" />
        <span class="gobierto-data-summary-header-container-label">
          {{ labelFrequency }}
        </span>
        <span class="gobierto-data-summary-header-container-text">
          Anual
        </span>
      </div>
      <div class="gobierto-data-summary-header-container">
        <i class="fas fa-tag" />
        <span class="gobierto-data-summary-header-container-label">
          {{ labelSubject }}
        </span>
        <a
          href=""
          class="gobierto-data-summary-header-container-text">
          Urbanismo e infraestructuras
        </a>
      </div>
    </div>
    <div class="pure-u-1-2">
      <p class="gobierto-data-summary-header-description">
        {{ datasetDescription }}
      </p>
    </div>
    <button class="gobierto-data-summary-btn-download-data">
      <i class="fas fa-download" />
      {{ labelDownloadData }}
    </button>
  </div>
</template>
<script>
export default {
  name: "Info",
  data() {
    return {
      labelUpdated: '',
      labelFrequency: '',
      labelSubject: '',
      labelDownloadData: '',
    }
  },
  created() {
    this.labelUpdated = I18n.t("gobierto_data.projects.updated")
    this.labelFrequency = I18n.t("gobierto_data.projects.frequency")
    this.labelSubject = I18n.t("gobierto_data.projects.subject")
    this.labelDownloadData = I18n.t("gobierto_data.projects.downloadData")
  }
}

</script>
