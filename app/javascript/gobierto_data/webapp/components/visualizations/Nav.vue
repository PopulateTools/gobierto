<template>
  <div>
    <nav class="gobierto-data-sets-nav">
      <ul>
        <li
          :class="{ 'is-active': activeTab === 0 }"
          class="gobierto-data-sets-nav--tab"
          @click="activateTab(0)"
        >
          <span>{{ labelSummary }}</span>
        </li>
        <li
          :class="{ 'is-active': activeTab === 1 }"
          class="gobierto-data-sets-nav--tab"
          @click="activateTab(1)"
        >
          <span>{{ labelData }}</span>
        </li>
        <li
          :class="{ 'is-active': activeTab === 2 }"
          class="gobierto-data-sets-nav--tab"
          @click="activateTab(2)"
        >
          <span>{{ labelQueries }}</span>
        </li>
        <li
          :class="{ 'is-active': activeTab === 3 }"
          class="gobierto-data-sets-nav--tab"
          @click="activateTab(3)"
        >
          <span>{{ labelVisualizations }}</span>
        </li>
        <li
          :class="{ 'is-active': activeTab === 4 }"
          class="gobierto-data-sets-nav--tab"
          @click="activateTab(4)"
        >
          <span>{{ labelDownload }}</span>
        </li>
      </ul>
    </nav>
    <DatasetsSummary v-if="activeTab === 0" />
    <DatasetsData v-if="activeTab === 1" />
    <DatasetsQueries v-if="activeTab === 2" />
    <DatasetsVisualizations v-if="activeTab === 3" />
    <DatasetsDownloads v-if="activeTab === 4" />
  </div>
</template>
<script>
import DatasetsSummary from "./Summary.vue";
import DatasetsData from "./Data.vue";
import DatasetsQueries from "./Queries.vue";
import DatasetsVisualizations from "./Visualizations.vue";
import DatasetsDownloads from "./Downloads.vue";


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
