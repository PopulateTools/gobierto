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
  },
  data() {
    return {
      description: null,
      category: {},
      frequency: {},
      dateUpdated: null,
    };
  },
  updated() {
    // We set those values in updated hook, because the component is already mounted
    ({
      data_updated_at: this.dateUpdated,
      category: [{ name_translations: this.category } = {}] = [],
      frequency: [{ name_translations: this.frequency } = {}] = [],
      description: this.description
    } = this.datasetAttributes) // Ouh yes, destructuring FTW 😎
  }
};
</script>
