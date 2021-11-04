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
      <InfoBlockText
        v-if="hasDatasetSource"
        icon="building"
        opacity=".25"
        :label="labelSource"
        :text="sourceDatasetText"
        :url="sourceDatasetUrl"
      />
      <InfoBlockText
        v-if="hasDatasetLicense"
        icon="certificate"
        opacity=".25"
        :label="labelLicense"
        :text="licenseDatasetText"
        :url="licenseDatasetUrl"
      />
    </div>
    <div class="pure-u-1-2">
      <div
        id="gobierto-data-summary-header"
        class="gobierto-data-summary-header-description"
        v-html="compiledHTMLMarkdown"
      />
      <template v-if="checkStringLength">
        <transition
          name="fade"
          mode="out-in"
        >
          <span
            v-if="truncateIsActive"
            class="gobierto-data-summary-header-description-link"
            @click="truncateIsActive = !truncateIsActive"
          >
            {{ seeMore }}
          </span>
          <span
            v-else
            class="gobierto-data-summary-header-description-link"
            @click="scrollDetail"
          >
            {{ seeLess }}
          </span>
        </transition>
      </template>
    </div>
  </div>
</template>
<script>
import { date, truncate } from "lib/vue/filters"
import InfoBlockText from "./../commons/InfoBlockText.vue";
//Parse markdown to HTML
const marked = require('marked');

export default {
  name: "Info",
  components: {
    InfoBlockText,
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
    licenseDataset: {
      type: Object,
      default: () => {}
    },
    sourceDataset: {
      type: Object,
      default: () => {}
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
      labelDownloadData: I18n.t("gobierto_data.projects.downloadData") || '',
      labelSource: I18n.t("gobierto_data.projects.sourceDataset") || '',
      labelSourceUrl: I18n.t("gobierto_data.projects.sourceDatasetUrl") || '',
      labelLicense: I18n.t("gobierto_data.projects.license") || '',
      seeMore: I18n.t("gobierto_common.vue_components.read_more.more") || '',
      seeLess: I18n.t("gobierto_common.vue_components.read_more.less") || '',
      truncateIsActive: true,
      sourceDatasetText: '',
      sourceDatasetUrl: '',
      licenseDatasetText: '',
      licenseDatasetUrl: ''
    }
  },
  computed: {
    compiledHTMLMarkdown() {
      const descriptionHTML = this.descriptionDataset.replace(/\|<br>/g, '|').replace(/<p>\|/g, '|').replace(/\|<\/p>/g, '|');
      const mdText = marked(descriptionHTML, {
        sanitize: false,
        tables: true
      })
      if (this.truncateIsActive) {
        return truncate(mdText, { length: 250 })
      } else {
        return mdText
      }
    },
    checkStringLength() {
      return this.descriptionDataset.length > 250
    },
    hasDatasetSource() {
      return this.sourceDataset && this.sourceDataset?.text !== undefined && this.sourceDataset?.text !== ""
    },
    hasDatasetLicense() {
      return this.licenseDataset?.text !== undefined && this.licenseDataset?.url !== undefined
    },
  },
  created(){
    if (this.sourceDataset) {
      const { text: sourceDatasetText, url: sourceDatasetUrl } = this.sourceDataset
      this.sourceDatasetText = sourceDatasetText
      this.sourceDatasetUrl = sourceDatasetUrl
    }
    if (this.licenseDataset) {
      const { text: licenseDatasetText, url: licenseDatasetUrl } = this.licenseDataset
      this.licenseDatasetText = licenseDatasetText
      this.licenseDatasetUrl = licenseDatasetUrl
    }
  },
  methods: {
    scrollDetail() {
      const element = document.getElementById('gobierto-datos-app');
      window.scrollTo({
        top: element.offsetTop,
        behavior: 'smooth'
      });
      this.truncateIsActive = true
    }
  }
}
</script>
