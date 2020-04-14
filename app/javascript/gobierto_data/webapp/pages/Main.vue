<template>
  <Layout>
    <template v-slot:sidebar>
      <Sidebar
        :active-tab="activeSidebarTab"
        :filters="filters"
      />
    </template>

    <template v-slot:main>
      <keep-alive>
        <router-view
          :key="$route.params.id"
          :all-datasets="subsetItems"
        />
      </keep-alive>
    </template>
  </Layout>
</template>

<script>
import Layout from "./../layouts/Layout.vue";
import Sidebar from "./../components/Sidebar.vue";
import { CategoriesMixin } from "./../../lib/mixins/categories.mixin";
import { FiltersMixin } from "./../../lib/mixins/filters.mixin";

export default {
  name: "Dataset",
  components: {
    Layout,
    Sidebar
  },
  mixins: [CategoriesMixin, FiltersMixin],
  props: {
    activeSidebarTab: {
      type: Number,
      default: 0
    }
  },
};
</script>
