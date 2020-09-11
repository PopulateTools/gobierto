<template>
  <Layout>
    <template v-slot:sidebar>
      <template v-if="!isDatasetLoaded">
        <SkeletonSpinner
          height-square="20px"
          squares-rows="1"
          squares="3"
        />
        <SkeletonSpinner
          squares="0"
          lines="4"
        />
      </template>
      <template v-else>
        <Sidebar
          :active-tab="activeSidebarTab"
          :filters="filters"
          :items="items"
          @active-tab="activeSidebarTab = $event"
        />
      </template>
    </template>
    <template v-slot:main>
      <template v-if="!isDatasetLoaded">
        <SkeletonSpinner
          height-square="200px"
          squares-rows="3"
          squares="1"
        />
      </template>
      <template v-else>
        <keep-alive>
          <router-view
            :key="$route.params.id"
            :all-datasets="subsetItems"
            :page-title="pageTitle"
          />
        </keep-alive>
      </template>
    </template>
  </Layout>
</template>

<script>
import { SkeletonSpinner } from "lib/vue-components";
import Layout from "./../layouts/Layout.vue";
import Sidebar from "./../components/Sidebar.vue";
import { CategoriesMixin } from "./../../lib/mixins/categories.mixin";
import { FiltersMixin } from "./../../lib/mixins/filters.mixin";

export default {
  name: "Dataset",
  components: {
    Layout,
    Sidebar,
    SkeletonSpinner
  },
  mixins: [CategoriesMixin, FiltersMixin],
  data() {
    return {
      activeSidebarTab: 0,
      pageTitle: ''
    }
  },
  watch: {
    $route(to) {
      if (to.name === 'Dataset') {
        this.activeSidebarTab = 1
      }
    }
  },
  computed: {
    isDatasetLoaded() {
      return this.items.length && this.subsetItems.length
    }
  },
  created() {
    this.$root.$on("sendCheckbox_TEMP", this.handleCheckboxStatus)
    this.$root.$on("selectAll_TEMP", this.handleIsEverythingChecked)
    this.pageTitle = document.title
  },
  deactivated() {
    this.$root.$off("sendCheckbox_TEMP")
    this.$root.$off("selectAll_TEMP")
  },
  methods: {
    setActiveSidebar() {
      if (this.$route.name === 'Dataset') {
        this.activeSidebarTab = 1
      }
    }
  }
};
</script>
