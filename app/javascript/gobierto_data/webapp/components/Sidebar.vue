<template>
  <div>
    <nav
      class="gobierto-data-tabs-sidebar"
      role="navigation"
      aria-label="sidebar navigation"
    >
      <div
        :class="{ 'is-active': activeTab === 0 }"
        class="gobierto-data-tab-sidebar--tab"
        @click="activateTab(0)"
      >
        <span>{{ labelCategories }}</span>
      </div>
      <div
        :class="{ 'is-active': activeTab === 1 }"
        class="gobierto-data-tab-sidebar--tab"
        @click="activateTab(1)"
      >
        <span>{{ labelSets }}</span>
      </div>

      <!-- <div
        :class="{ 'is-active': activeTab === 2 }"
        class="gobierto-data-tab-sidebar--tab"
        @click="activateTab(2)"
      >
        <span>{{ labelQueries }}</span>
      </div> -->
    </nav>

    <keep-alive>
      <component
        :is="currentTabComponent"
        v-bind="$attrs"
        @update="handleUpdate"
      />
    </keep-alive>
  </div>
</template>

<script>
// ESBuild does not work properly with dynamic components
import SidebarCategories from './sidebar/SidebarCategories.vue';
import SidebarDatasets from './sidebar/SidebarDatasets.vue';
import SidebarQueries from './sidebar/SidebarQueries.vue';

const COMPONENTS = [
  SidebarCategories,
  SidebarDatasets,
  SidebarQueries
];
// define the components as dynamic
// const COMPONENTS = [
//   () => import('./sidebar/SidebarCategories.vue'),
//   () => import('./sidebar/SidebarDatasets.vue'),
//   () => import('./sidebar/SidebarQueries.vue')
// ];

export default {
  name: "Sidebar",
  inheritAttrs: false,
  props: {
    activeTab: {
      type: Number,
      default: 0
    },
  },
  data() {
    return {
      labelSets: I18n.t("gobierto_data.projects.sets") || "",
      // labelQueries: I18n.t("gobierto_data.projects.queries") || "",
      labelCategories: I18n.t("gobierto_data.projects.categories") || "",
      currentTabComponent: null,
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
  },
  methods: {
    activateTab(index) {
      this.$emit("active-tab", index)
    },
    handleUpdate(items) {
      this.$emit("update", items)
    }
  }
};
</script>
