<template>
  <div
    v-if="publicVisualizations.length"
    class="gobierto-data-visualization--grid"
  >
    <template v-for="{ items, config, name, id, columns, slug, datasetName } in publicVisualizations">
      <router-link
        :key="id"
        :to="`/datos/${slug}/v/${id}`"
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
                :object-columns="columns"
                :config="config"
              />
              <router-link
                :to="`/datos/${slug}/`"
                class="gobierto-data-visualizations-name"
              >
                <h4 class="gobierto-data-visualization--dataset">
                  {{ datasetName }}
                </h4>
              </router-link>
            </div>
          </div>
        </div>
      </router-link>
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
    datasetName: {
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
