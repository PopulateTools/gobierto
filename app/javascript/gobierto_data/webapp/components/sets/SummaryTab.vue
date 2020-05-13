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


    <router-link
      :to="`/datos/${$route.params.id}/${tabs[1]}`"
    >
      <Button
        :text="labelPreview"
        icon="table"
        color="var(--color-base)"
        class="gobierto-data-btn-download-data"
        background="#fff"
      />
    </router-link>

    <Resources :resources-list="resourcesList" />

    <Description :array-columns="arrayColumns" />

    <Dropdown @is-content-visible="showYourQueries = !showYourQueries">
      <template v-slot:trigger>
        <h2 class="gobierto-data-tabs-section-title">
          <Caret :rotate="showYourQueries" />
          {{ labelQueries }}
        </h2>
      </template>
      <div>
        <Queries
          v-if="showYourQueries"
          :private-queries="privateQueries"
          :public-queries="publicQueries"
        />
      </div>
    </Dropdown>
  </div>
</template>

<script>
import Resources from "./../commons/Resources.vue";
import Info from "./../commons/Info.vue";
import DownloadButton from "./../commons/DownloadButton.vue";
import Button from "./../commons/Button.vue";
import Queries from "./../commons/Queries.vue";
import Caret from "./../commons/Caret.vue";
import Description from "./../commons/Description.vue";
import { tabs } from '../../../lib/router'
import { Dropdown } from "lib/vue-components";
import { translate } from "lib/shared"

export default {
  name: "SummaryTab",
  components: {
    Resources,
    Queries,
    DownloadButton,
    Button,
    Info,
    Caret,
    Dropdown,
    Description
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
    arrayColumns: {
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
      labelQueries: I18n.t("gobierto_data.projects.queries") || "",
      labelPreview: I18n.t("gobierto_data.projects.preview") || "",
      tabs
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
