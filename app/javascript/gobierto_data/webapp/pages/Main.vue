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
        v-bind="attrs"
        @active-tab="activeSidebarTab = $event"
        @update="handleUpdate"
      />
    </template>

    <SkeletonSpinner
      v-if="!isDatasetLoaded"
      height-square="200px"
      squares-rows="3"
      squares="1"
    />
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
import { DatasetFactoryMixin } from "./../../lib/factories/datasets";
// import { translate } from "lib/vue/filters";

export default {
  name: "Main",
  components: {
    Layout,
    Sidebar,
    SkeletonSpinner
  },
  mixins: [CategoriesMixin, DatasetFactoryMixin],
  data() {
    return {
      activeSidebarTab: 0,
      pageTitle: "",
      attrs: {},
      items: []
    };
  },
  computed: {
    categories() {
      const { dictionary = [] } = this.middleware || {};
      // We need to extract the human-readable elements from the dictionary
      const { attributes: { vocabulary_terms: categories = [] } = {} } =
        dictionary.find(({ attributes: { uid } = {} }) => uid === "category") ||
        {};

      return categories;
    },
    frequencies() {
      const { dictionary = [] } = this.middleware || {};
      // We need to extract the human-readable elements from the dictionary
      const { attributes: { vocabulary_terms: frequencies = [] } = {} } =
        dictionary.find(
          ({ attributes: { uid } = {} }) => uid === "frequency"
        ) || {};

      return frequencies;
    },
    parsedSubsetItems() {
      return this.items;
      // return this.subsetItems.map(
      //   ({
      //     id,
      //     attributes: {
      //       slug,
      //       name,
      //       description,
      //       data_updated_at,
      //       category: category_id,
      //       frequency: frequency_id
      //     }
      //   }) => {
      //     let category = null;
      //     let frequency = null;

      //     if (category_id) {
      //       // convert into arrays
      //       const selectedCategories = Array.isArray(category_id)
      //         ? category_id
      //         : [category_id];
      //       // get only the translated strings, separated by commas
      //       category = (
      //         this.categories.reduce((acc, { id, name_translations }) => {
      //           if (selectedCategories.includes(id.toString())) {
      //             acc.push(translate(name_translations));
      //           }
      //           return acc;
      //         }, []) || []
      //       ).join(", ");
      //     }

      //     if (frequency_id) {
      //       const selectedFrequencies = Array.isArray(frequency_id)
      //         ? frequency_id
      //         : [frequency_id];

      //       frequency = (
      //         this.frequencies.reduce((acc, { id, name_translations }) => {
      //           if (selectedFrequencies.includes(id.toString())) {
      //             acc.push(translate(name_translations));
      //           }
      //           return acc;
      //         }, []) || []
      //       ).join(", ");
      //     }

      //     return {
      //       id,
      //       slug,
      //       name,
      //       description,
      //       data_updated_at,
      //       category,
      //       frequency
      //     };
      //   }
      // );
    },
    isDatasetLoaded() {
      // return this.items.length && this.subsetItems.length;
      return true;
    }
  },
  watch: {
    $route(to) {
      if (to.name === "Dataset") {
        this.activeSidebarTab = 1;
      }
    }
  },
  async created() {
    this.pageTitle = document.title;

    const [
      {
        data: { data: items = [] }
      },
      {
        data: { data: metadata = [], meta: stats = {} }
      }
    ] = await Promise.all([
      this.getDatasets(),
      this.getDatasetsMetadata({ stats: true })
    ]);

    // TODO: completar los fields de manera adecuada
    this.attrs = {
      items,
      metadata,
      stats,
      fields: [
        {
          id: "category",
          flat: true
        },
        {
          id: "frequency",
          flat: true
        }
      ]
    };
  },
  methods: {
    handleUpdate(items) {
      this.items = items
    }
  }
};
</script>
