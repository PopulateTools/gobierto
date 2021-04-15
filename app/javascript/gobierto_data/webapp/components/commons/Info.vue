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
        v-if="sourceDataset"
        icon="link"
        opacity=".25"
        :label="labelSource"
        :text="sourceDataset"
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
const TurndownService = require('turndown').default;

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
    sourceDataset: {
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
      labelDownloadData: I18n.t("gobierto_data.projects.downloadData") || '',
      labelSource: I18n.t("gobierto_data.projects.license") || '',
      seeMore: I18n.t("gobierto_common.vue_components.read_more.more") || '',
      seeLess: I18n.t("gobierto_common.vue_components.read_more.less") || '',
      truncateIsActive: true
    }
  },
  computed: {
    compiledHTMLMarkdown() {
      const turndownService = new TurndownService()
      const markdown = turndownService.turndown(this.descriptionDataset)
      const mdText = marked(markdown, {
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
