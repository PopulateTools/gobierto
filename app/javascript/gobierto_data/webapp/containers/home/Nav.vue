<template>
  <nav class="gobierto-data-home-nav">
    <ul>
      <li
        :class="{ 'is-active': activeTab === 0 }"
        class="gobierto-data-home-nav--tab"
        @click="activateTab(0)"
      >
        <span>{{ labelDatasets }}</span>
      </li>
      <li
        :class="{ 'is-active': activeTab === 1 }"
        class="gobierto-data-home-nav--tab"
        @click="activateTab(1)"
      >
        <span>{{ labelQueries }}</span>
      </li>
      <li
        :class="{ 'is-active': activeTab === 2 }"
        class="gobierto-data-home-nav--tab"
        @click="activateTab(2)"
      >
        <span>{{ labelVisualizations }}</span>
      </li>
      <li
        :class="{ 'is-active': activeTab === 3 }"
        class="gobierto-data-home-nav--tab"
        @click="activateTab(3)"
      >
        <span>{{ labelDashboards }}</span>
      </li>
      <li
        :class="{ 'is-active': activeTab === 4 }"
        class="gobierto-data-home-nav--tab"
        @click="activateTab(4)"
      >
        <span>{{ labelAnalysis }}</span>
      </li>
      <li
        :class="{ 'is-active': activeTab === 5 }"
        class="gobierto-data-home-nav--tab"
        @click="activateTab(5)"
      >
        <span>{{ labelNews }}</span>
      </li>
      <li
        :class="{ 'is-active': activeTab === 6 }"
        class="gobierto-data-home-nav--tab"
        @click="activateTab(6)"
      >
        <span>{{ labelInformation }}</span>
      </li>
      <li
        :class="{ 'is-active': activeTab === 7 }"
        class="gobierto-data-home-nav--tab"
        @click="activateTab(7)"
      >
        <span>{{ labelAPI }}</span>
      </li>
    </ul>
  </nav>
</template>

<script>
export default {
  name: "HomeNav",
  props: {
    activeTab: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      labelDatasets: "",
      labelQueries: "",
      labelVisualizations: "",
      labelDashboards: "",
      labelAnalysis: "",
      labelNews: "",
      labelInformation: "",
      labelAPI: ""
    };
  },
  created() {
    this.labelDatasets = I18n.t("gobierto_data.projects.dataset")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelVisualizations = I18n.t("gobierto_data.projects.visualizations")
    this.labelDashboards = I18n.t("gobierto_data.projects.dashboards")
    this.labelAnalysis = I18n.t("gobierto_data.projects.analysis")
    this.labelNews = I18n.t("gobierto_data.projects.news")
    this.labelInformation = I18n.t("gobierto_data.projects.info")
    this.labelAPI = I18n.t("gobierto_data.projects.api")
  },
  methods: {
    activateTab(index) {
      this.$emit("active-tab", index);
    }
  }
};
</script>
