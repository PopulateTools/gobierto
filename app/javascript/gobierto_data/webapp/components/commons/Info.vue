<template>
  <div class="pure-g">
    <div class="pure-u-1-2 gobierto-data-summary-header">
      <div class="gobierto-data-summary-header-container">
        <template v-if="dateUpdated">
          <i
            class="fas fa-clock"
            style="color: var(--color-base); opacity: .25"
          />
          <span class="gobierto-data-summary-header-container-label">
            {{ labelUpdated }}
          </span>
          <span class="gobierto-data-summary-header-container-text">
            {{ dateUpdated | convertDate }}
          </span>
        </template>
      </div>
      <template v-if="frequencyDataset">
        <div class="gobierto-data-summary-header-container">
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
      </template>
      <template v-if="categoryDataset">
        <div class="gobierto-data-summary-header-container">
          <i
            class="fas fa-tag"
            style="color: var(--color-base); opacity: .25"
          />
          <span class="gobierto-data-summary-header-container-label">
            {{ labelSubject }}
          </span>
          <a
            href="#"
            class="gobierto-data-summary-header-container-text-link"
          >
            {{ categoryDataset }}
          </a>
        </div>
      </template>
    </div>
    <div class="pure-u-1-2">
      <div
        class="gobierto-data-summary-header-description"
        v-html="descriptionDataset"
      />
    </div>
  </div>
</template>
<script>
import { date } from "lib/shared"

export default {
  name: "Info",
  filters: {
    convertDate(valueDate) {
      return date(valueDate, {
        day : 'numeric',
        month : 'short',
        year : 'numeric'
      })
    }
  },
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
    },
    arrayFormats: {
      type: Object,
      default: () => {},
    },
  },
  data() {
    return {
      labelUpdated: I18n.t("gobierto_data.projects.updated") || '',
      labelFrequency: I18n.t("gobierto_data.projects.frequency") || '',
      labelSubject: I18n.t("gobierto_data.projects.subject") || '',
      labelDownloadData: I18n.t("gobierto_data.projects.downloadData") || ''
    }
  }
}
</script>
