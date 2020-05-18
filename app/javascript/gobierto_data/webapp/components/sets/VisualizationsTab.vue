<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <component
      :is="currentVizComponent"
      v-if="publicVisualizations"
      :public-visualizations="publicVisualizations"
      :private-visualizations="privateVisualizations"
      :dataset-id="datasetId"
      :is-user-logged="isUserLogged"
      :is-public-loading="isPublicLoading"
      :is-private-loading="isPrivateLoading"
      :items="items"
      :config="config"
      :name="titleViz"
      :is-viz-saving-prompt-visible="isVizSavingPromptVisible"
      :is-viz-modified="isVizModified"
      :is-viz-saved="isVizSaved"
      :is-private-viz-loading="isPrivateVizLoading"
      :is-public-viz-loading="isPublicVizLoading"
      :enabled-viz-saved-button="enabledVizSavedButton"
      @changeViz="showVizElement"
      @emitDelete="deleteHandlerVisualization"
    />
  </div>
</template>
<script>

import { VisualizationFactoryMixin } from "./../../../lib/factories/visualizations";

const COMPONENTS = [
  () => import("./VisualizationsList.vue"),
  () => import("./VisualizationsItem.vue")
];

export default {
  name: "VisualizationsTab",
  mixins: [
    VisualizationFactoryMixin,
  ],
  props: {
    datasetId: {
      type: Number,
      required: true
    },
    isUserLogged: {
      type: Boolean,
      default: false
    },
    isVizModified: {
      type: Boolean,
      default: false
    },
    isVizSaved: {
      type: Boolean,
      default: false
    },
    isVizSavingPromptVisible: {
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
    isPrivateVizLoading: {
      type: Boolean,
      default: false
    },
    isPublicVizLoading: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      currentVizComponent: null,
      items: '',
      isPrivateLoading: false,
      isPublicLoading: false,
      titleViz: '',
      activeViz: 0,
      config: {}
    };
  },
  created() {

    const {
      name: nameComponent
    } = this.$route;

    if (nameComponent === 'Visualization') {
      this.showVizElement(1)
    } else {
      this.currentVizComponent = COMPONENTS[this.activeViz];
    }
    this.$root.$emit('reloadVisualizations')

  },
  methods: {
    showVizElement(component) {
      this.activeViz = component
      this.currentVizComponent = COMPONENTS[this.activeViz];
    },
    deleteHandlerVisualization(id) {
      this.deleteVisualization(id)
      this.$root.$emit('reloadVisualizations')
    }
  }
};
</script>
