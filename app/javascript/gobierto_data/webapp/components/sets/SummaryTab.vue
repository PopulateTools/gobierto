<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <Info
      :description-dataset="description"
      :category-dataset="category | translate"
      :frequency-dataset="frequency | translate"
      :date-updated="dateUpdated"
    />

    <DownloadButton
      :array-formats="arrayFormats"
      class="arrow-top modal-left"
    />

    <Resources :resources-list="resourcesList" />

    <Queries
      :private-queries="privateQueries"
      :public-queries="publicQueries"
      :user-is-not-logged="userIsNotLogged"
    />
  </div>
</template>

<script>
import Resources from "./../commons/Resources.vue";
import Info from "./../commons/Info.vue";
import DownloadButton from "./../commons/DownloadButton.vue";
import Queries from "./../commons/Queries.vue";
import { translate } from "lib/shared"

export default {
  name: "SummaryTab",
  components: {
    Resources,
    Queries,
    DownloadButton,
    Info,
  },
  filters: {
    translate
  },
  props: {
    privateQueries: {
      type: Array,
      default: () => [],
    },
    publicQueries: {
      type: Array,
      default: () => [],
    },
    arrayFormats: {
      type: Object,
      default: () => {},
    },
    datasetAttributes: {
      type: Object,
      default: () => {},
    },
    resourcesList: {
      type: Array,
      required: true,
      default: () => [],
    },
    userIsNotLogged: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      description: null,
      category: {},
      frequency: {},
      dateUpdated: null,
    };
  },
  created() {
    ({
      data_updated_at: this.dateUpdated,
      category: [{ name_translations: this.category } = {}] = [],
      frequency: [{ name_translations: this.frequency } = {}] = [],
      description: this.description
    } = this.datasetAttributes) // Ouh yes, destructuring FTW 😎
  }
};
</script>
