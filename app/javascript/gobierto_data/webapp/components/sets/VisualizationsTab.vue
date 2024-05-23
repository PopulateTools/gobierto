<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <template v-if="!isVizLoading">
      <template v-if="listVizComponent">
        <SkeletonSpinner
          height-square="200px"
          squares-rows="2"
          squares="2"
        />
      </template>
      <template v-else>
        <SkeletonSpinner
          height-square="300px"
          squares="1"
          lines="2"
        />
      </template>
    </template>
    <template v-else>
      <component
        :is="currentVizComponent"
        v-if="isVizLoading"
        :public-visualizations="publicVisualizations"
        :private-visualizations="privateVisualizations"
        :private-queries="privateQueries"
        :public-queries="publicQueries"
        :dataset-id="datasetId"
        :is-user-logged="isUserLogged"
        :is-public-loading="isPublicLoading"
        :is-private-loading="isPrivateLoading"
        :name="titleViz"
        :is-viz-saving-prompt-visible="isVizSavingPromptVisible"
        :is-viz-modified="isVizModified"
        :is-viz-saved="isVizSaved"
        :is-private-viz-loading="isPrivateVizLoading"
        :is-public-viz-loading="isPublicVizLoading"
        :enabled-viz-saved-button="enabledVizSavedButton"
        :enabled-fork-viz-button="enabledForkVizButton"
        :viz-input-focus="vizInputFocus"
        :show-private-public-icon-viz="showPrivatePublicIconViz"
        :show-private-viz="showPrivateViz"
        :show-private="showPrivate"
        :show-label-edit="showLabelEdit"
        :is-viz-item-modified="isVizItemModified"
        :reset-private="resetPrivate"
        :viz-id="vizId"
        :user-save-viz="userSaveViz"
        :object-columns="objectColumns"
        :config-map="configMap"
        :registration-disabled="registrationDisabled"
        @changeViz="showVizElement"
        @emitDelete="deleteHandlerVisualization"
      />
    </template>
  </div>
</template>
<script>
import { SkeletonSpinner } from '../../../../lib/vue/components';
import { VisualizationFactoryMixin } from '../../../lib/factories/visualizations';

// ESBuild does not work properly with dynamic components
import VisualizationsList from './VisualizationsList.vue';
import VisualizationsItem from './VisualizationsItem.vue';

const COMPONENTS = [
  VisualizationsList,
  VisualizationsItem
];
// const COMPONENTS = [
//   () => import('./VisualizationsList.vue'),
//   () => import('./VisualizationsItem.vue')
// ];

export default {
  name: "VisualizationsTab",
  components: {
    SkeletonSpinner
  },
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
    privateQueries: {
      type: Array,
      default: () => []
    },
    publicQueries: {
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
    vizId: {
      type: Number,
      default: 0
    },
    userSaveViz: {
      type: Number,
      default: 0
    },
    objectColumns: {
      type: Object,
      default: () => {}
    },
    configMap: {
      type: Object,
      default: () => {}
    },
    registrationDisabled: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      currentVizComponent: null,
      items: null,
      isPrivateLoading: false,
      isPublicLoading: false,
      listVizComponent: true,
      titleViz: '',
      activeViz: 0,
      config: {}
    };
  },
  computed: {
    isVizLoading() {
      return this.publicVisualizations.length || !this.isPublicVizLoading
    }
  },
  watch: {
    currentVizTab(newValue) {
      if (newValue === 0) {
        this.currentVizComponent = COMPONENTS[newValue];
      }
    }
  },
  created() {
    const {
      name: nameComponent
    } = this.$route;

    if (nameComponent === 'Visualization') {
      this.currentVizComponent = COMPONENTS[1];
      this.listVizComponent = false
    } else {
      this.currentVizComponent = COMPONENTS[this.activeViz];
      this.listVizComponent = true
    }
  },
  mounted() {
    this.$root.$emit('showSavingDialogEventViz', false)
  },
  methods: {
    showVizElement(component) {
      this.activeViz = component
      this.currentVizComponent = COMPONENTS[this.activeViz];
    },
    async deleteHandlerVisualization(id) {
      await this.deleteVisualization(id)
      this.$root.$emit('reloadVisualizations')
    }
  }
};
</script>
