<template>
  <div>
    <div class="pure-g">
      <div class="pure-u-1-2">
        <h2 class="gobierto-data-title-dataset">
          {{ titleDataset }}
        </h2>
      </div>
      <div class="pure-u-1-2 gobierto-data-buttons">
        <Button
          :text="labelFav"
          icon="star"
          color="#fff"
          background="var(--color-base)"
        />
        <Button
          :text="labelFollow"
          icon="bell"
          color="#fff"
          background="var(--color-base)"
        />
      </div>
    </div>
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
    <keep-alive>
      <Summary
        v-if="activeTab === 0"
        :array-queries="arrayQueries"
        :array-formats="arrayFormats"
      />
      <Data
        v-else-if="activeTab === 1"
        :dataset-id="datasetId"
        :array-queries="arrayQueries"
        :array-columns="arrayColumns"
        :table-name="tableName"
        :array-formats="arrayFormats"
      />
      <Queries
        v-else-if="activeTab === 2"
        :array-queries="arrayQueries"
      />
      <Visualizations v-else-if="activeTab === 3" />
      <Downloads
        v-else-if="activeTab === 4"
        :array-formats="arrayFormats"
      />
    </keep-alive>
  </div>
</template>
<script>
import Button from "./../commons/Button.vue";
import Summary from "./Summary.vue";
import Data from "./Data.vue";
import Queries from "./Queries.vue";
import Visualizations from "./Visualizations.vue";
import Downloads from "./Downloads.vue";


export default {
  name: "NavSets",
  components: {
    Summary,
    Data,
    Queries,
    Visualizations,
    Downloads,
    Button
  },
  props: {
    activeTab: {
      type: Number,
      default: 0
    },
    datasetId: {
      type: Number,
      default: 0
    },
    arrayQueries: {
      type: Array,
      required: true
    },
    arrayColumns: {
      type: Array,
      required: true
    },
    arrayFormats: {
      type: Object,
      required: true
    },
    tableName: {
      type: String,
      required: true
    },
    titleDataset: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      labelSummary: "",
      labelData: "",
      labelQueries: "",
      labelVisualizations: "",
      labelDownload: "",
      labelFav: "",
      labelFollow: "",
      slugName: ''
    }
  },
  created() {
    this.labelSummary = I18n.t("gobierto_data.projects.summary")
    this.labelData = I18n.t("gobierto_data.projects.data")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelVisualizations = I18n.t("gobierto_data.projects.visualizations")
    this.labelDownload = I18n.t("gobierto_data.projects.download")
    this.labelFav = I18n.t("gobierto_data.projects.fav")
    this.labelFollow = I18n.t("gobierto_data.projects.follow")

    this.$root.$on('changeNavTab', this.changeTab)
    this.$root.$on('activeTabIndex', this.changeTab)

    this.slugName = this.$route.params.id
  },
  methods: {
    changeTab() {
      this.activateTab(1)
    },
    activateTab(index) {
      this.$emit("active-tab", index);
    }
  }
}

</script>
