<template>
  <div
    v-if="publicVisualizations && publicVisualizations.length"
    class="gobierto-data-visualization--grid"
  >
    <template v-for="{ items, config, columns, name, id, slug, datasetName } in publicVisualizations">
      <router-link
        :key="id"
        :to="`/datos/${slug}/v/${id}`"
        class="gobierto-data-visualizations-name"
      >
        <CardVisualization>
          <template v-slot:title>
            {{ name }}
          </template>
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
        </CardVisualization>
      </router-link>
    </template>
  </div>
</template>
<script>
import Visualizations from "./../commons/Visualizations.vue";
import CardVisualization from "./../../layouts/CardVisualization.vue";
export default {
  name: "VisualizationsGrid",
  components: {
    Visualizations,
    CardVisualization
  },
  props: {
    publicVisualizations: {
      type: Array,
      default: () => []
    }
  }
};
</script>
