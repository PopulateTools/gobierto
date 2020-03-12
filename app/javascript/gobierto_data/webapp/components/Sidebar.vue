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
    initData(){
      const endPoint = `${baseUrl}/datasets`
      axios
        .get(endPoint)
        .then(response => {
          const rawData = response.data

          const sortDatasets = rawData.data
          this.allDatasets = sortDatasets.sort((a, b) => a.attributes.name.localeCompare(b.attributes.name));

          let slug = this.$route.params.id

          this.indexToggle = this.allDatasets.findIndex(dataset => dataset.attributes.slug == slug)
          this.toggle = this.indexToggle
          if (this.toggle < 0) {
            this.toggle = 0
            slug = this.allDatasets[0].attributes.slug
          }
          let firstElement = this.allDatasets.find(dataset => dataset.attributes.slug == slug)
          let filteredArray = this.allDatasets.filter(dataset => dataset.attributes.slug !== slug)
          filteredArray.unshift(firstElement)
          this.allDatasets = filteredArray
          this.toggle = 0
        })
        .catch(error => {
          console.error(error)
        })
    },
    handleToggle(index) {
      this.toggle = this.toggle !== index ? index : null;
    },
    activateTab(index) {
      this.$emit("active-tab-sidebar", index);
    }
  }
}
</script>
