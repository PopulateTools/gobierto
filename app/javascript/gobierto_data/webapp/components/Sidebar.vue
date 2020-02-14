<template>
  <div class="pure-u-1 pure-u-lg-1-4 gobierto-data-layout-column gobierto-data-layout-sidebar">
    <nav class="gobierto-data-tabs-sidebar">
      <ul>
        <li
          :class="{ 'is-active': activeTab === 0 }"
          class="gobierto-data-tab-sidebar--tab"
          @click="activateTab('SidebarCategories', 0)"
        >
          <span>{{ labelCategories }}</span>
        </li>
        <li
          :class="{ 'is-active': activeTab === 1 || activeTab === 4 }"
          class="gobierto-data-tab-sidebar--tab"
          @click="activateTab('SidebarDatasets', 1)"
        >
          <span>{{ labelSets }}</span>
        </li>

        <li
          :class="{ 'is-active': activeTab === 2 }"
          class="gobierto-data-tab-sidebar--tab"
          @click="activateTab('SidebarQueries', 2)"
        >
          <span>{{ labelQueries }}</span>
        </li>
      </ul>
    </nav>
    <component
      :is="selectedComponent"
      v-bind="componentProperties"
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
    }
  },
  data() {
    return {
      labelSets: "",
      labelQueries: "",
      labelCategories: "",
      selectedComponent: 'SidebarCategories'
    }
  },
  computed: {
    componentProperties: function() {
      if (this.selectedComponent === 'SidebarCategories') {
        return {
          parentId: 0
        }
      } else if (this.selectedComponent === 'SidebarDatasets') {
        return {
          parentId: 1
        }
      } else if (this.selectedComponent === 'SidebarQueries') {
        return {
          parentId: 2
        }
      }
    }
  },
  created() {
    this.labelSets = I18n.t("gobierto_data.projects.sets")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelCategories = I18n.t("gobierto_data.projects.categories")
  },
  mounted() {
    this.$root.$on('value', data => {
      this.selectedComponent = data
    })
  },
  methods: {
    activateTab(value, index) {
      this.selectedComponent = value
      this.$emit("active-tab", index);

    }
  }
}
</script>
