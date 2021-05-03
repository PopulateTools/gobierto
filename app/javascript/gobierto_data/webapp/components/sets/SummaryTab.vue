<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <Info
      :description-dataset="description"
      :category-dataset="category | translate"
      :frequency-dataset="frequency | translate"
      :license-dataset="datasetLicense"
      :source-dataset="datasetSourceObject"
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
      v-if="hasQueries"
      class="gobierto-data-summary-separator"
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
        :is-user-logged="isUserLogged"
        :private-queries="privateQueries"
        :public-queries="publicQueries"
      />
    </Dropdown>

    <template v-if="!isVizLoading">
      <SkeletonSpinner
        height-square="300px"
        squares="2"
        lines="2"
      />
    </template>
    <template v-else>
      <Dropdown
        v-if="hasVisualizations"
        @is-content-visible="showYourVizs = !showYourVizs"
      >
        <template v-slot:trigger>
          <h2 class="gobierto-data-tabs-section-title">
            <Caret :rotate="showYourVizs" />
            {{ labelVisualizations }}
          </h2>
        </template>
        <VisualizationsTab
          v-if="showYourVizs"
          class="gobierto-data-summary-visualizations"
          :dataset-id="datasetId"
          :is-user-logged="isUserLogged"
          :is-viz-modified="isVizModified"
          :is-viz-item-modified="isVizItemModified"
          :is-viz-saved="isVizSaved"
          :is-private-viz-loading="isPrivateVizLoading"
          :is-public-viz-loading="isPublicVizLoading"
          :public-visualizations="publicVisualizations"
          :private-visualizations="privateVisualizations"
          :private-queries="privateQueries"
          :public-queries="publicQueries"
          :enabled-viz-saved-button="enabledVizSavedButton"
          :current-viz-tab="currentVizTab"
          :enabled-fork-viz-button="enabledForkVizButton"
          :viz-input-focus="vizInputFocus"
          :user-save-viz="userSaveViz"
          :show-private-public-icon-viz="showPrivatePublicIconViz"
          :show-private="showPrivate"
          :show-private-viz="showPrivateViz"
          :show-label-edit="showLabelEdit"
          :reset-private="resetPrivate"
          :object-columns="objectColumns"
        />
      </Dropdown>
    </template>
  </div>
</template>

<script>
import VisualizationsTab from "./VisualizationsTab.vue";
import Resources from "./../commons/Resources.vue";
import Info from "./../commons/Info.vue";
import Queries from "./../commons/Queries.vue";
import Caret from "./../commons/Caret.vue";
import Description from "./../commons/Description.vue";
import DownloadButton from "./../commons/DownloadButton.vue";
import Button from "./../commons/Button.vue";
import { tabs } from '../../../lib/router'
import { translate } from "lib/vue/filters"
import { Dropdown, SkeletonSpinner } from "lib/vue/components";

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
    Description,
    VisualizationsTab,
    SkeletonSpinner
  },
  filters: {
    translate
  },
  props: {
    datasetId: {
      type: Number,
      required: true
    },
    isVizModified: {
      type: Boolean,
      default: false
    },
    isVizSaved: {
      type: Boolean,
      default: false
    },
    enabledVizSavedButton: {
      type: Boolean,
      default: false
    },
    privateVisualizations: {
      type: Array,
      default: () => []
    },
    publicVisualizations: {
      type: Array,
      default: () => []
    },
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
    },
    isPrivateVizLoading: {
      type: Boolean,
      default: false
    },
    isPublicVizLoading: {
      type: Boolean,
      default: false
    },
    currentVizTab: {
      type: Number,
      default: null
    },
    enabledForkVizButton: {
      type: Boolean,
      default: true
    },
    vizInputFocus: {
      type: Boolean,
      default: true
    },
    showPrivatePublicIconViz: {
      type: Boolean,
      default: false
    },
    showPrivateViz: {
      type: Boolean,
      default: false
    },
    showPrivate: {
      type: Boolean,
      default: false
    },
    showLabelEdit: {
      type: Boolean,
      default: false
    },
    isVizItemModified: {
      type: Boolean,
      default: false
    },
    resetPrivate: {
      type: Boolean,
      default: false
    },
    userSaveViz: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      description: null,
      category: {},
      frequency: {},
      dateUpdated: null,
      datasetLicense: null,
      datasetSource: null,
      datasetSourceUrl: null,
      datasetSourceObject: {},
      showYourQueries: true,
      showYourVizs: true,
      labelQueries: I18n.t("gobierto_data.projects.queries") || "",
      labelPreview: I18n.t("gobierto_data.projects.preview") || "",
      labelVisualizations: I18n.t("gobierto_data.projects.visualizations") || "",
      tabs
    };
  },
  computed: {
    isVizLoading() {
      return this.publicVisualizations.length || !this.isPublicVizLoading
    },
    hasQueries() {
      return this.privateQueries?.length || this.publicQueries?.length
    },
    hasVisualizations() {
      return this.privateVisualizations?.length || this.publicVisualizations?.length
    }
  },
  created() {
    ({
      data_updated_at: this.dateUpdated,
      category: [{ name_translations: this.category } = {}] = [],
      frequency: [{ name_translations: this.frequency } = {}] = [],
      "dataset-license": [{ name_translations: this.datasetLicense } = {}] = [],
      "dataset-source": this.datasetSource,
      "dataset-source-url": this.datasetSourceUrl,
      description: this.description
    } = this.datasetAttributes) // Ouh yes, destructuring FTW 😎
    this.datasetSourceObject = {
      es: this.datasetSource,
      url: this.datasetSourceUrl
    }
  }
};
</script>
