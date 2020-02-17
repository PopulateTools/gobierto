<template>
  <div class="pure-u-1 pure-u-lg-1-4 gobierto-data-layout-column gobierto-data-layout-sidebar">
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
    <SidebarCategories
      v-if="activeTab === 0"
      :filters="filters"
    />
    <SidebarDatasets
      v-if="activeTab === 1"
      :filters="filters"
      :datasets="datasets"
    />
    <SidebarQueries
      v-if="activeTab === 2"
    />
  </div>
</template>
<script>
import SidebarCategories from './SidebarCategories.vue';
import SidebarDatasets from './SidebarDatasets.vue';
import SidebarQueries from './SidebarQueries.vue';
export default {
  name: "Sidebar",
  components: {
    SidebarCategories,
    SidebarDatasets,
    SidebarQueries
  },
  props: {
    activeTab: {
      type: Number,
      default: 0
    },
    filters: {
      type: Array,
      default: () => []
    },
    datasets: {
      type: Array,
      default: () => []
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
}
</script>
