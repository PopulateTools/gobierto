<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <Info
      :description-dataset="description"
      :category-dataset="category | translate"
      :frequency-dataset="frequency | translate"
      :date-updated="dateUpdated"
      :array-formats="arrayFormats"
    />

    <div class="gobierto-data-summary-header-btns gobierto-data-summary-separator">
      <DownloadButton
        :array-formats="arrayFormats"
        class="arrow-top modal-left"
      />

      <router-link
        :to="`/datos/${$route.params.id}/${tabs[1]}`"
        class="gobierto-data-btn-preview"
      >
        <Button
          :text="labelPreview"
          icon="table"
          color="rgba(var(--color-base)"
          icon-color="rgba(var(--color-base-string), .5)"
          class="gobierto-data-btn-download-data "
          background="#fff"
        />
      </router-link>
    </div>

    <Resources
      :resources-list="resourcesList"
      class="gobierto-data-summary-separator"
    />

    <Description
      :object-columns="objectColumns"
      class="gobierto-data-summary-separator"
    />

    <Dropdown
      v-if="privateQueries.length || publicQueries.length"
      @is-content-visible="showYourQueries = !showYourQueries"
    >
      <template v-slot:trigger>
        <h2 class="gobierto-data-tabs-section-title">
          <Caret :rotate="showYourQueries" />
          {{ labelQueries }}
        </h2>
      </template>
      <Queries
        v-if="showYourQueries"
        :private-queries="privateQueries"
        :public-queries="publicQueries"
      />
    </Dropdown>
  </div>
</template>

<script>
import Resources from "./../commons/Resources.vue";
import Info from "./../commons/Info.vue";
import Queries from "./../commons/Queries.vue";
import Caret from "./../commons/Caret.vue";
import Description from "./../commons/Description.vue";
import DownloadButton from "./../commons/DownloadButton.vue";
import Button from "./../commons/Button.vue";
import { tabs } from '../../../lib/router'
import { Dropdown } from "lib/vue-components";
import { translate } from "lib/shared"

export default {
  name: "SummaryTab",
  components: {
    Resources,
    Queries,
    Info,
    Caret,
    Dropdown,
    DownloadButton,
    Button,
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
    objectColumns: {
      type: Object,
      default: () => {},
    },
    datasetAttributes: {
      type: Object,
      default: () => {},
    },
    resourcesList: {
      type: Array,
      default: () => [],
    },
    isUserLogged: {
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
