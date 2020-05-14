<template>
  <nav class="gobierto-data-home-nav">
    <ul>
      <router-link
        :to="'/datos/'"
        :class="{ 'is-active': activeTab === 0 }"
        class="gobierto-data-home-nav--tab"
      >
        <span>{{ labelDatasets }}</span>
      </router-link>
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
// TODO: component UNREVIEWED YET
export default {
  name: "Nav",
  props: {
    activeTab: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      labelDatasets: I18n.t("gobierto_data.projects.dataset") || '',
      labelQueries:  I18n.t("gobierto_data.projects.queries") || '',
      labelVisualizations:  I18n.t("gobierto_data.projects.visualizations") || '',
      labelDashboards:  I18n.t("gobierto_data.projects.dashboards") || '',
      labelAnalysis:  I18n.t("gobierto_data.projects.analysis") || '',
      labelNews:  I18n.t("gobierto_data.projects.news") || '',
      labelInformation:  I18n.t("gobierto_data.projects.info") || '',
      labelAPI:  I18n.t("gobierto_data.projects.api") || ''
    }
  },
  methods: {
    activateTab(index) {
      this.$emit("active-tab", index);
    },
    nav(index) {
      this.$emit("active-tab", index);
      this.$router.push({
        name: "home"
      // eslint-disable-next-line no-unused-vars
      }).catch(err => {})
    }
  }
};

</script>
