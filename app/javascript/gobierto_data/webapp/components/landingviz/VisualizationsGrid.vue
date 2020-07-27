<template>
  <div
    v-if="publicVisualizations.length"
    class="gobierto-data-visualization--grid"
  >
    <template v-for="{ items, config, name, id } in publicVisualizations">
      <div :key="id">
        <router-link
          :to="`/datos/${datasetSlug}/v/${id}`"
          class="gobierto-data-visualizations-name"
        >
          <div class="gobierto-data-visualization--card">
            <div class="gobierto-data-visualization--aspect-ratio-16-9">
              <div class="gobierto-data-visualization--content">
                <h4 class="gobierto-data-visualization--title">
                  {{ name }}
                </h4>
                <Visualizations
                  v-if="items"
                  :items="items"
                  :object-columns="objectColumns"
                  :config="config"
                />
              </div>
            </div>
          </div>
        </router-link>
      </div>
    </template>
  </div>
</template>
<script>
import Visualizations from "./../commons/Visualizations.vue";
export default {
  name: "VisualizationsGrid",
  components: {
    Visualizations
  },
  props: {
    publicVisualizations: {
      type: Array,
      default: () => []
    },
    datasetSlug: {
      type: String,
      default: ''
    },
    objectColumns: {
      type: Object,
      default: () => {}
    }
  }
};
</script>
