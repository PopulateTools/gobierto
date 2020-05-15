<template>
  <div>
    <template v-if="items">
      <h2 class="gobierto-data-visualitzation-element-title">
        {{ name }}
      </h2>
      <div class="gobierto-data-visualization--aspect-ratio-16-9">
        <Visualizations
          :items="items"
          :config="config"
        />
      </div>
    </template>
  </div>
</template>
<script>
import Visualizations from "./../commons/Visualizations.vue";


export default {
  name: "VisualizationsItem",
  components: {
    Visualizations
  },
  props: {
    datasetId: {
      type: Number,
      required: true
    },
    isUserLogged: {
      type: Boolean,
      default: false
    },
    items: {
      type: String,
      default: ''
    },
    name: {
      type: String,
      default: ''
    },
    config: {
      type: Object,
      default: () => {}
    }
  }
};
</script>
