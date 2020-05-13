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

    <Button
      :text="'Previsualizar'"
      icon="table"
      color="var(--color-base)"
      class="gobierto-data-btn-download-data"
      background="#fff"
    />

    <Resources :resources-list="resourcesList" />

    <h2
      class="gobierto-data-tabs-section-title"
      @click="showYourQueries = !showYourQueries"
    >
      <Caret :rotate="showYourQueries" />
      {{ labelQueries }}
    </h2>
    <Queries
      v-if="showYourQueries"
      :private-queries="privateQueries"
      :public-queries="publicQueries"
    />
  </div>
</template>

<script>
import Resources from "./../commons/Resources.vue";
import Info from "./../commons/Info.vue";
import DownloadButton from "./../commons/DownloadButton.vue";
import Button from "./../commons/Button.vue";
import Queries from "./../commons/Queries.vue";
import Caret from "./../commons/Caret.vue";
import { translate } from "lib/shared"

export default {
  name: "SummaryTab",
  components: {
    Resources,
    Queries,
    DownloadButton,
    Button,
    Info,
    Caret
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
      showYourQueries: true,
      labelQueries: I18n.t("gobierto_data.projects.queries") || ""
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
