<template>
  <div class="pure-g">
    <div class="pure-u-17-24 gobierto-data-summary-header">
      <div
        v-if="compiledHTMLMarkdown"
        id="gobierto-data-summary-header"
        class="gobierto-data-summary-header-description gobierto-data-summary-separator"
        v-html="compiledHTMLMarkdown"
      />
      <div class="gobierto-data-summary-separator">
        <InfoBlockText
          v-if="numberOfRows"
          icon="database"
          :icon-color="'#666'"
          :label="labelNumberOfRows"
          :text="formatNumberOfRows"
        />
        <InfoBlockText
          v-if="dateUpdated"
          icon="clock"
          :icon-color="'#666'"
          :label="labelUpdated"
          :text="dateUpdated | convertDate"
        />
        <InfoBlockText
          v-if="frequencyDataset"
          icon="calendar"
          :icon-color="'#666'"
          :label="labelFrequency"
          :text="frequencyDataset"
        />
        <InfoBlockText
          v-if="categoryDataset"
          icon="tag"
          :icon-color="'#666'"
          :label="labelSubject"
          :text="categoryDataset"
        />
        <InfoBlockText
          v-if="hasDatasetSource"
          icon="building"
          :icon-color="'#666'"
          :label="labelSource"
          :text="sourceDatasetText"
          :url="sourceDatasetUrl"
        />
        <InfoBlockText
          v-if="hasDatasetLicense"
          icon="certificate"
          :icon-color="'#666'"
          :label="labelLicense"
          :text="licenseDatasetText"
          :url="licenseDatasetUrl"
        />
      </div>
    </div>
    <div class="pure-u-7-24 gobierto-data-summary-info-tab">
      <div
        class="gobierto-data-summary-header-btns"
      >
        <template v-if="moreThanOneFormat">
          <DownloadButton
            :array-formats="arrayFormats"
            class="arrow-top modal-left"
          />
        </template>
        <template v-else>
          <DownloadLink
            :editor="false"
            :array-formats="arrayFormats"
          />
        </template>
        <router-link
          :to="`/datos/${$route.params.id}/${tabs[1]}`"
          class="gobierto-data-btn-preview"
        >
          <Button
            :text="labelPreview"
            icon="table"
            icon-color="rgba(var(--color-base-string), .5)"
            class="gobierto-data-btn-download-data "
            background="#fff"
          />
        </router-link>
      </div>
    </div>
  </div>
</template>
<script>
import { date } from "lib/vue/filters";
import { formatNumbers } from "lib/shared";
import InfoBlockText from "./../commons/InfoBlockText.vue";
import DownloadButton from "./../commons/DownloadButton.vue";
import DownloadLink from "./../commons/DownloadLink.vue";
import Button from "./../commons/Button.vue";
import { tabs } from "../../../lib/router";
//Parse markdown to HTML. Related: https://github.com/PopulateTools/issues/issues/1428#issuecomment-1026617835
const marked = require('marked');

export default {
  name: "InfoTab",
  components: {
    InfoBlockText,
    DownloadButton,
    DownloadLink,
    Button
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
      default: () => {}
    },
    numberOfRows: {
      type: Number,
      default: 0
    },
  },
  data() {
    return {
      labelUpdated: I18n.t("gobierto_data.projects.updated") || '',
      labelNumberOfRows: I18n.t("gobierto_data.projects.numberOfRows") || '',
      labelFrequency: I18n.t("gobierto_data.projects.frequency") || '',
      labelSubject: I18n.t("gobierto_data.projects.subject") || '',
      labelDownloadData: I18n.t("gobierto_data.projects.downloadData") || '',
      labelSource: I18n.t("gobierto_data.projects.sourceDataset") || '',
      labelSourceUrl: I18n.t("gobierto_data.projects.sourceDatasetUrl") || '',
      labelLicense: I18n.t("gobierto_data.projects.license") || '',
      seeMore: I18n.t("gobierto_common.vue_components.read_more.more") || '',
      seeLess: I18n.t("gobierto_common.vue_components.read_more.less") || '',
      labelPreview: I18n.t("gobierto_data.projects.preview") || "",
      sourceDatasetText: '',
      sourceDatasetUrl: '',
      licenseDatasetText: '',
      licenseDatasetUrl: '',
      tabs
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
      return markdownText
    },
    hasDatasetSource() {
      return this.sourceDataset && this.sourceDataset?.text !== undefined && this.sourceDataset?.text !== ""
    },
    hasDatasetLicense() {
      return this.licenseDataset?.text !== undefined && this.licenseDataset?.url !== undefined
    },
    moreThanOneFormat() {
      return Object.keys(this.arrayFormats).length > 1
    },
    formatNumberOfRows() {
      return formatNumbers(this.numberOfRows)
    }
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
  }
}
</script>
