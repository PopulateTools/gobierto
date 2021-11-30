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
          <img :src="config.base64">
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
import CardVisualization from "./../../layouts/CardVisualization.vue";
export default {
  name: "VisualizationsGrid",
  components: {
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
