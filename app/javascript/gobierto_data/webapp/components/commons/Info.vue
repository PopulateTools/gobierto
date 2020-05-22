<template>
  <div class="pure-g">
    <div class="pure-u-1-2 gobierto-data-summary-header">
      <InfoBlockText
        v-if="dateUpdated"
        icon="clock"
        opacity=".25"
        :label="labelUpdated"
        :text="dateUpdated | convertDate"
      />
      <InfoBlockText
        v-if="frequencyDataset"
        icon="calendar"
        opacity=".25"
        :label="labelFrequency"
        :text="frequencyDataset"
      />
      <InfoBlockText
        v-if="categoryDataset"
        icon="tag"
        opacity=".25"
        :label="labelSubject"
        :text="categoryDataset"
      />
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
import InfoBlockText from "./../commons/InfoBlockText.vue";

export default {
  name: "Info",
  components: {
    InfoBlockText
  },
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
