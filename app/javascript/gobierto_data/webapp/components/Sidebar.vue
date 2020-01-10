<template>
  <div class="pure-u-1 pure-u-lg-1-4 gobierto-data-layout-column gobierto-data-layout-sidebar">
    <nav class="gobierto-data-home-nav">
      <ul>
        <li
          :class="{ 'is-active': activeTab === 0 }"
          class="gobierto-data-home-nav--tab"
          @click="activateTab(0)"
        >
          <span>{{ labelSets }}</span>
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
          <span>{{ labelCategories }}</span>
        </li>
      </ul>
    </nav>
  </div>
</template>

<script>
export default {
  name: "Sidebar",
  props: {
    activeTab: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      labelSets: "",
      labelQueries: "",
      labelCategories: ""
    }
  },
  created() {
    this.labelSets = I18n.t("gobierto_data.projects.sets")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelCategories = I18n.t("gobierto_data.projects.categories")
  },
  methods: {
    activateTab(index) {
      this.$emit("active-tab", index);
    }
  }
};
</script>
