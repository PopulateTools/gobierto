<template>
  <div>
    <div class="pure-g">
      <div class="pure-u-1-2 gobierto-data-summary-header">
        <div class="gobierto-data-summary-header-container">
          <i class="fas fa-clock" />
          <span class="gobierto-data-summary-header-container-label">
            {{ labelUpdated }}
          </span>
          <span class="gobierto-data-summary-header-container-text">
            {{ datasetDate }}
          </span>
        </div>
        <div class="gobierto-data-summary-header-container">
          <i class="fas fa-calendar" />
          <span class="gobierto-data-summary-header-container-label">
            {{ labelFrequency }}
          </span>
          <span class="gobierto-data-summary-header-container-text">
            {{ datasetFrequency }}
          </span>
        </div>
        <div class="gobierto-data-summary-header-container">
          <i class="fas fa-tag" />
          <span class="gobierto-data-summary-header-container-label">
            {{ labelSubject }}
          </span>
          <a
            href=""
            class="gobierto-data-summary-header-container-text-link"
          >
            {{ datasetSubject }}
          </a>
        </div>
      </div>
      <div class="pure-u-1-2">
        <p class="gobierto-data-summary-header-description">
          {{ datasetDescription }}
        </p>
      </div>
    </div>
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
      datasetDate: '',
      datasetFrequency: '',
      datasetSubject: '',
      datasetDescription: ''
    }
  },
  created() {
    this.labelUpdated = I18n.t("gobierto_data.projects.updated")
    this.labelFrequency = I18n.t("gobierto_data.projects.frequency")
    this.labelSubject = I18n.t("gobierto_data.projects.subject")
    this.labelDownloadData = I18n.t("gobierto_data.projects.downloadData")
  },
  methods: {
    updateSummaryInfo(values) {
      const { 0: updatedDate, 1: frequency, 2: subject, 3: description } = values

      this.datasetDate = this.datasetDate === undefined ? '' : updatedDate
      this.datasetFrequency = this.datasetFrequency === undefined ? '' : frequency
      this.datasetSubject = this.datasetSubject === undefined ? '' : subject
      this.datasetDescription = this.datasetDescription === undefined ? '' : description

      this.datasetDate = new Date(this.datasetDate)
      this.datasetDate = this.datasetDate.toLocaleDateString('es-ES', {
          day : 'numeric',
          month : 'short',
          year : 'numeric'
      })

    }
  }
}

</script>
