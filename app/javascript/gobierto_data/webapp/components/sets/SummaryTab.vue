<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <InfoTab
      :description-dataset="description"
      :category-dataset="category | translate"
      :frequency-dataset="frequency | translate"
      :license-dataset="datasetLicenseObject"
      :source-dataset="datasetSourceObject"
      :date-updated="dateUpdated"
      :array-formats="arrayFormats"
    />

    <Resources
      :resources-list="resourcesList"
      class="gobierto-data-summary-separator"
    />

    <Description
      :object-columns="objectColumns"
      class="gobierto-data-summary-separator gobierto-data-description-columns"
    />

    <Dropdown
      v-if="hasGeometry && items.length"
      class="gobierto-data-summary-separator"
      @is-content-visible="showMap = !showMap"
    >
      <template v-slot:trigger>
        <h2 class="gobierto-data-tabs-section-title">
          <Caret :rotate="showMap" />
          {{ labelMap }}
        </h2>
      </template>
      <div class="gobierto-data-visualization--aspect-ratio-16-9">
        <Visualizations
          v-if="showMap"
          :items="items"
          :config="config"
          :object-columns="objectColumns"
          :config-map="configMap"
        />
      </div>
    </Dropdown>

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
import Visualizations from "./../commons/Visualizations.vue";
import Resources from "./../commons/Resources.vue";
import InfoTab from "./../commons/InfoTab.vue";
import Queries from "./../commons/Queries.vue";
import Caret from "./../commons/Caret.vue";
import Description from "./../commons/Description.vue";
import { tabs } from "../../../lib/router";
import { translate } from "lib/vue/filters";
import { Dropdown, SkeletonSpinner } from "lib/vue/components";

export default {
  name: "SummaryTab",
  components: {
    Resources,
    Queries,
    InfoTab,
    Caret,
    Dropdown,
    Description,
    VisualizationsTab,
    SkeletonSpinner,
    Visualizations
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
      default: () => []
    },
    publicQueries: {
      type: Array,
      default: () => []
    },
    arrayFormats: {
      type: Object,
      default: () => {}
    },
    objectColumns: {
      type: Object,
      default: () => {}
    },
    datasetAttributes: {
      type: Object,
      default: () => {}
    },
    resourcesList: {
      type: Array,
      default: () => []
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
    },
    items: {
      type: String,
      default: ""
    },
    configMap: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      description: null,
      category: {},
      frequency: {},
      dateUpdated: null,
      datasetLicense: null,
      datasetLicenseUrl: null,
      datasetSource: null,
      datasetSourceUrl: null,
      datasetSourceObject: {},
      datasetLicenseObject: {},
      showYourQueries: true,
      showYourVizs: true,
      showMap: true,
      labelQueries: I18n.t("gobierto_data.projects.queries") || "",
      labelVisualizations:
        I18n.t("gobierto_data.projects.visualizations") || "",
      labelMap: I18n.t("gobierto_data.projects.map") || "",
      tabs,
      config: {
        plugin: "map"
      }
    };
  },
  computed: {
    isVizLoading() {
      return this.publicVisualizations.length || !this.isPublicVizLoading;
    },
    hasQueries() {
      return this.privateQueries?.length || this.publicQueries?.length;
    },
    hasVisualizations() {
      return (
        this.privateVisualizations?.length || this.publicVisualizations?.length
      );
    },
    hasGeometry() {
      return Object.keys(this.objectColumns).some(x => x === "geometry");
    },
    moreThanOneFormat() {
      return Object.keys(this.arrayFormats).length > 1
    }
  },
  created() {
    ({
      data_updated_at: this.dateUpdated,
      category: [{ name_translations: this.category } = {}] = [],
      frequency: [{ name_translations: this.frequency } = {}] = [],
      "dataset-license": [{ name_translations: this.datasetLicense, description_translations: this.datasetLicenseUrl } = {}] = [],
      "dataset-source": this.datasetSource,
      "dataset-source-url": this.datasetSourceUrl,
      description: this.description
    } = this.datasetAttributes) // Ouh yes, destructuring FTW 😎
    this.datasetSourceObject = {
      text: this.datasetSource,
      url: this.datasetSourceUrl
    }
    this.datasetLicenseObject = {
      text: translate(this.datasetLicense),
      url: translate(this.datasetLicenseUrl)
    }
  }
};
</script>
