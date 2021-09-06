<template>
  <Layout>
    <template #sidebar>
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
      <Sidebar
        v-else
        :active-tab="activeSidebarTab"
        :filters="filters"
        :items="items"
        @active-tab="activeSidebarTab = $event"
      />
    </template>

    <template v-if="!isDatasetLoaded">
      <SkeletonSpinner
        height-square="200px"
        squares-rows="3"
        squares="1"
      />
    </template>
    <keep-alive v-else>
      <router-view
        :key="$route.params.id"
        :datasets="parsedSubsetItems"
        :page-title="pageTitle"
      />
    </keep-alive>
  </Layout>
</template>

<script>
import { SkeletonSpinner } from "lib/vue/components";
import Layout from "./../layouts/Layout.vue";
import Sidebar from "./../components/Sidebar.vue";
import { CategoriesMixin } from "./../../lib/mixins/categories.mixin";
import { FiltersMixin } from "./../../lib/mixins/filters.mixin";
import { VueFiltersMixin } from "lib/vue/filters";

export default {
  name: "Main",
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
    categories() {
      const { dictionary = [] } = this.middleware || {};
      // We need to extract the human-readable elements from the dictionary
      const { attributes: { vocabulary_terms: categories = [] } = {} } = dictionary.find(
        ({ attributes: { uid } = {} }) => uid === "category"
      ) || {};

      return categories
    },
    frequencies() {
      const { dictionary = [] } = this.middleware || {};
      // We need to extract the human-readable elements from the dictionary
      const { attributes:{ vocabulary_terms: frequencies = [] } = {} } = dictionary.find(
        ({ attributes: { uid } = {} }) => uid === "frequency"
      ) || {};

      return frequencies
    },
    parsedSubsetItems() {
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
          let category = null;
          let frequency = null;

          if (category_id) {
            // convert into arrays
            const selectedCategories = Array.isArray(category_id)
              ? category_id
              : [category_id];
            // get only the translated strings, separated by commas
            category = (this.categories.reduce((acc, { id, name_translations }) => {
              if (selectedCategories.includes(id.toString())) {
                acc.push(this.translate(name_translations))
              }
              return acc
            }, []) || []).join(", ");
          }

          if (frequency_id) {
            const selectedFrequencies = Array.isArray(frequency_id)
              ? frequency_id
              : [frequency_id];

            frequency = (this.frequencies.reduce((acc, { id, name_translations }) => {
              if (selectedFrequencies.includes(id.toString())) {
                acc.push(this.translate(name_translations))
              }
              return acc
            }, []) || []).join(", ");
          }

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
    this.$root.$on("selectCheckboxPermalink_TEMP", this.handleCheckboxFilter);
    this.pageTitle = document.title;
  },
  deactivated() {
    this.$root.$off("sendCheckbox_TEMP");
    this.$root.$off("selectAll_TEMP");
    this.$root.$off("selectCheckboxPermalink_TEMP");
  }
};
</script>
