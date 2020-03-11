<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <div class="gobierto-data-infolist">
    </div>
    <div
      v-for="(item, index) in allDatasets"
      :key="index"
      class="gobierto-data-info-list-element"
    >
      <a
        :href="'/datos/' + item.attributes.slug"
        class="gobierto-data-title-dataset gobierto-data-title-dataset-big"
        @click.prevent="nav(item.attributes.slug)"
      >
        {{ item.attributes.name }}
      </a>
      <div class="pure-g">
        <div class="pure-u-1-2 gobierto-data-summary-header">
          <div class="gobierto-data-summary-header-container">
            <i
              class="fas fa-clock"
              style="color: var(--color-base); opacity: .25"
            />
            <span class="gobierto-data-summary-header-container-label">
              {{ labelUpdated }}
            </span>
            <span class="gobierto-data-summary-header-container-text">
              {{ item.attributes.data_updated_at | date }}
            </span>
          </div>
          <div
            v-if="item.attributes.frequency[0].name_translations"
            class="gobierto-data-summary-header-container"
          >
            <i
              class="fas fa-calendar"
              style="color: var(--color-base); opacity: .25"
            />
            <span class="gobierto-data-summary-header-container-label">
              {{ labelFrequency }}
            </span>
              <span class="gobierto-data-summary-header-container-text">
                {{ item.attributes.frequency[0].name_translations | translate }}
              </span>
          </div>
          <div
            v-if="item.attributes.category[0].name_translations"
            class="gobierto-data-summary-header-container"
          >
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
                {{ item.attributes.frequency[0].name_translations | translate }}
              </a>
          </div>
        </div>
        <div class="pure-u-1-2">
          <p class="gobierto-data-summary-header-description">
            {{ item.attributes.description }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>
<script>

import { VueFiltersMixin } from "lib/shared";
export default {
  name: "InfoList",
  mixins: [VueFiltersMixin],
  props: {
    allDatasets: {
      type: Array,
      default: () => []
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
  },
  methods: {
    nav(slugDataset) {
      this.$router.push({
        name: "dataset",
        params: {
          id: slugDataset,
          tabSidebar: 1,
          currentComponent: 'DataSets'
        }
      // eslint-disable-next-line no-unused-vars
      }).catch(err => {})
    }
  }
}
</script>
