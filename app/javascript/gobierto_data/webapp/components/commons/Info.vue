<template>
  <div>
    <div class="pure-g">
      <div class="pure-u-1-2 gobierto-data-summary-header">
        <div v-if="dateUpdated" class="gobierto-data-summary-header-container">
          <i
            class="fas fa-clock"
            style="color: var(--color-base); opacity: .25"
          />
          <span class="gobierto-data-summary-header-container-label">
            {{ labelUpdated }}
          </span>
          <span class="gobierto-data-summary-header-container-text">
            {{ dateUpdated }}
          </span>
        </div>
        <div v-if="frequencyDataset" class="gobierto-data-summary-header-container">
          <i
            class="fas fa-calendar"
            style="color: var(--color-base); opacity: .25"
          />
          <span class="gobierto-data-summary-header-container-label">
            {{ labelFrequency }}
          </span>
          <span class="gobierto-data-summary-header-container-text">
            {{ frequencyDataset }}
          </span>
        </div>
        <div v-if="categoryDataset" class="gobierto-data-summary-header-container">
          <i
            class="fas fa-tag"
            style="color: var(--color-base); opacity: .25"
          />
          <span class="gobierto-data-summary-header-container-label">
            {{ labelSubject }}
          </span>
          <a
            href=""
            class="gobierto-data-summary-header-container-text-link"
          >
            {{ categoryDataset }}
          </a>
        </div>
      </div>
      <div class="pure-u-1-2">
        <p class="gobierto-data-summary-header-description">
          {{ descriptionDataset }}
        </p>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  name: "Info",
  props: {
    descriptionDataset: {
      type: String,
      default: ''
    },
    categoryDataset: {
      type: String,
      default: ''
    },
    frequencyDataset: {
      type: String,
      default: ''
    },
    dateUpdated: {
      type: String,
      default: ''
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
