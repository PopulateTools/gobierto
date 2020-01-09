<template>
  <nav class="gobierto-data-sets-nav">
    <ul>
      <li
        :class="{ 'is-active': activeTab === 0 }"
        class="gobierto-data-sets-nav--tab"
        @click="activateTab(0)"
      >
        <span>{{ labelSummary }}</span>
        <DatasetsSummary />
      </li>
      <li
        :class="{ 'is-active': activeTab === 1 }"
        class="gobierto-data-sets-nav--tab"
        @click="activateTab(1)"
      >
        <span>{{ labelData }}</span>
        <DatasetsData />
      </li>
      <li
        :class="{ 'is-active': activeTab === 2 }"
        class="gobierto-data-sets-nav--tab"
        @click="activateTab(2)"
      >
        <span>{{ labelQueries }}</span>
        <DatasetsQueries />
      </li>
      <li
        :class="{ 'is-active': activeTab === 3 }"
        class="gobierto-data-sets-nav--tab"
        @click="activateTab(3)"
      >
        <span>{{ labelVisualizations }}</span>
        <DatasetsVisualizations />
      </li>
      <li
        :class="{ 'is-active': activeTab === 4 }"
        class="gobierto-data-sets-nav--tab"
        @click="activateTab(4)"
      >
        <span>{{ labelDownload }}</span>
      </li>
      <DatasetsDownloads />
    </ul>
  </nav>
</template>

<script>
import DatasetsSummary from "./DatasetsSummary.vue";
import DatasetsData from "./DatasetsData.vue";
import DatasetsQueries from "./DatasetsQueries.vue";
import DatasetsVisualizations from "./DatasetsVisualizations.vue";
import DatasetsDownloads from "./DatasetsDownloads.vue";


export default {
  name: "NavSets",
  components: {
    DatasetsSummary,
    DatasetsData,
    DatasetsQueries,
    DatasetsVisualizations,
    DatasetsDownloads
  },
  props: {
    activeTab: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      labelSummary: "",
      labelData: "",
      labelQueries: "",
      labelVisualizations: "",
      labelDownload: ""
    }
  },
  created() {
    this.labelSummary = I18n.t("gobierto_data.projects.summary")
    this.labelData = I18n.t("gobierto_data.projects.data")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelVisualizations = I18n.t("gobierto_data.projects.visualizations")
    this.labelDownload = I18n.t("gobierto_data.projects.download")
  },
  methods: {
    activateTab(index) {
      this.$emit("active-tab", index);
    }
  }
};
</script>
