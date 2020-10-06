<template>
  <div>
    <nav class="gobierto-data-tabs-sidebar">
      <ul>
        <li
          :class="{ 'is-active': activeTab === 0 }"
          class="gobierto-data-tab-sidebar--tab"
          @click="activateTab(0)"
        >
          <span>{{ labelCategories }}</span>
        </li>
        <li
          :class="{ 'is-active': activeTab === 1 }"
          class="gobierto-data-tab-sidebar--tab"
          @click="activateTab(1)"
        >
          <span>{{ labelSets }}</span>
        </li>

        <li
          :class="{ 'is-active': activeTab === 2 }"
          class="gobierto-data-tab-sidebar--tab"
          @click="activateTab(2)"
        >
          <span>{{ labelQueries }}</span>
        </li>
      </ul>
    </nav>

    <keep-alive>
      <component
        :is="currentTabComponent"
        :filters="reFilters"
        :items="items"
      />
    </keep-alive>
  </div>
</template>
<script>
// define the components as dynamic
const COMPONENTS = [
  () => import("./sidebar/SidebarCategories.vue"),
  () => import("./sidebar/SidebarDatasets.vue"),
  () => import("./sidebar/SidebarQueries.vue")
];

export default {
  name: "Sidebar",
  props: {
    activeTab: {
      type: Number,
      default: 0
    },
    filters: {
      type: Array,
      default: () => []
    },
    items: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelSets: I18n.t("gobierto_data.projects.sets") || "",
      labelQueries: I18n.t("gobierto_data.projects.queries") || "",
      labelCategories: I18n.t("gobierto_data.projects.categories") || "",
      currentTabComponent: null
    };
  },
  watch: {
    activeTab(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.currentTabComponent = COMPONENTS[newValue];
      }
    }
  },
  created() {
    this.currentTabComponent = COMPONENTS[this.activeTab];

    this.reFilters = this.filters.map((element) => {
      return { ...element, options: element.options.filter((subElement) => subElement.counter > 0) }
    })
  },
  methods: {
    activateTab(index) {
      this.$emit('active-tab', index)
    }
  }
};
</script>
