<template>
  <div>
    <h1
      class="gobierto-data-title-dataset gobierto-data-title-dataset-big"
    >
      {{ items }}
    </h1>
    <div class="pure-g">
      <div class="pure-u-1-2 gobierto-data-summary-header">
        <div class="gobierto-data-summary-header-container">
          <i class="fas fa-clock" />
          <span class="gobierto-data-summary-header-container-label">
            {{ labelUpdated }}
          </span>
          <span class="gobierto-data-summary-header-container-text">
            {{ items.file.date }}
          </span>
        </div>
        <div class="gobierto-data-summary-header-container">
          <i class="fas fa-calendar" />
          <span class="gobierto-data-summary-header-container-label">
            {{ labelFrequency }}
          </span>
          <span class="gobierto-data-summary-header-container-text">
            {{ items.file.frequency }}
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
            {{ item.attributes.category[0].name_translations.es }}
          </a>
        </div>
      </div>
      <div class="pure-u-1-2">
        <p class="gobierto-data-summary-header-description">
          {{ item.file.description }}
        </p>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  name: "Info",
  props: {
    items: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      labelUpdated: '',
      labelFrequency: '',
      labelSubject: '',
      labelDownloadData: ''
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
