<template>
  <Layout>
    <template v-slot:sidebar>
      <template v-if="!items.length">
        <SkeletonSpinner
          height-square="100px"
          squares="1"
          squares-rows="2"
          lines="3"
        />
      </template>
      <template v-else>
        <Sidebar
          v-if="items.length"
          :active-tab="activeSidebarTab"
          :filters="filters"
          :items="items"
          @active-tab="activeSidebarTab = $event"
        />
      </template>
    </template>

    <template v-slot:main>
      <template v-if="!subsetItems.length">
        <SkeletonSpinner
          height-square="250px"
          squares="2"
          squares-rows="2"
          lines="4"
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
