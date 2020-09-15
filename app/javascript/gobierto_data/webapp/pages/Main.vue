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
            :datasets="parsedSubsetItems"
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
import { VueFiltersMixin } from "lib/shared";

export default {
  name: "Dataset",
  components: {
    Layout,
    Sidebar,
    SkeletonSpinner
  },
  mixins: [CategoriesMixin, FiltersMixin, VueFiltersMixin],
  data() {
    return {
      activeSidebarTab: 0,
      pageTitle: ""
    };
  },
  computed: {
    parsedSubsetItems() {
      const { dictionary = [] } = this.middleware || {};
      // We need to extract the human-readable elements from the dictionary
      const { attributes: { vocabulary_terms: categories = [] } = {} } = dictionary.find(
        ({ attributes: { uid } = {} }) => uid === "category"
      ) || {};
      const { attributes:{ vocabulary_terms: frequencies = [] } = {} } = dictionary.find(
        ({ attributes: { uid } = {} }) => uid === "frequency"
      ) || {};

      return this.subsetItems.map(
        ({
          id,
          attributes: {
            slug,
            name,
            description,
            data_updated_at,
            category: category_id,
            frequency: frequency_id
          }
        }) => {
          // convert into arrays
          const selectedCategories = Array.isArray(category_id)
            ? +category_id
            : [+category_id];
          const selectedFrequencies = Array.isArray(frequency_id)
            ? +frequency_id
            : [+frequency_id];

          // get only the translated strings, separated by commas
          const category = (categories.reduce((acc, { id, name_translations }) => {
            if (selectedCategories.includes(id)) {
              acc.push(this.translate(name_translations))
            }
            return acc
          }, []) || []).join(", ");
          const frequency = (frequencies.reduce((acc, { id, name_translations }) => {
            if (selectedFrequencies.includes(id)) {
              acc.push(this.translate(name_translations))
            }
            return acc
          }, []) || []).join(", ");

          return {
            id,
            slug,
            name,
            description,
            data_updated_at,
            category,
            frequency
          };
        }
      );
    },
    isDatasetLoaded() {
      return this.items.length && this.subsetItems.length;
    }
  },
  watch: {
    $route(to) {
      if (to.name === "Dataset") {
        this.activeSidebarTab = 1;
      }
    }
  },
  created() {
    this.$root.$on("sendCheckbox_TEMP", this.handleCheckboxStatus);
    this.$root.$on("selectAll_TEMP", this.handleIsEverythingChecked);
    this.pageTitle = document.title;
  },
  deactivated() {
    this.$root.$off("sendCheckbox_TEMP");
    this.$root.$off("selectAll_TEMP");
  },
  methods: {
    setActiveSidebar() {
      if (this.$route.name === "Dataset") {
        this.activeSidebarTab = 1;
      }
    }
  }
};
</script>
