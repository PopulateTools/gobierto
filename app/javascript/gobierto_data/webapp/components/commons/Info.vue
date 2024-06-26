<template>
  <div class="pure-g">
    <div class="pure-u-1-1 gobierto-data-summary-header gobierto-data-summary-info">
      <h2 class="gobierto-data-title-dataset gobierto-data-info-list-title">
        {{ titleDataset }}
      </h2>
      <InfoBlockText
        v-if="categoryDataset"
        icon="tag"
        :text="categoryDataset"
      />
      <div class="gobierto-data-info-list-top">
        <InfoBlockText
          v-if="dateUpdated"
          icon="clock"
          :text="dateUpdated | convertDate"
        />
        <InfoBlockText
          v-if="frequencyDataset"
          icon="calendar"
          :text="frequencyDataset"
        />
      </div>
    </div>
    <div class="pure-u-1-1 gobierto-data-summary-body">
      <div
        id="gobierto-data-summary-header"
        class="gobierto-data-summary-header-description"
        v-html="compiledHTMLMarkdown"
      />
      <i class="fas fa-arrow-right" />
    </div>
  </div>
</template>
<script>
import { date, truncate } from '../../../../lib/vue/filters';
import InfoBlockText from '../commons/InfoBlockText.vue';

//Parse markdown to HTML. Related: https://github.com/PopulateTools/issues/issues/1428#issuecomment-1026617835
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
    titleDataset: {
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
      /*This method is to remove only the <p>| |</p> and |<br> elements that CodeMirror adds when exporting from the editor. We need to remove them to convert the Markdown tables to HTML correctly.*/
      const descriptionHTML = this.descriptionDataset.replace(/\|<br>|<p>\||\|<\/p>/g, '|');
      const markdownText = marked(descriptionHTML, {
        sanitize: false,
        tables: true
      })
      if (this.truncateIsActive) {
        return truncate(markdownText, { length: 150 })
      } else {
        return markdownText
      }
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
