<template>
  <div
    v-if="publicVisualizations && publicVisualizations.length"
    class="gobierto-data-visualization--grid"
  >
    <template v-for="{ config, name, id, slug, datasetName, items, columns } in publicVisualizations">
      <router-link
        :key="id"
        :to="`/datos/${slug}/v/${id}`"
        class="gobierto-data-visualizations-name"
      >
        <CardVisualization>
          <template v-slot:title>
            {{ name }}
          </template>
          <template v-if="config.base64">
            <img
              class="gobierto-data-visualization--image"
              :src="config.base64"
            >
          </template>
          <template v-else>
            <Visualizations
              v-if="items"
              :items="items"
              :object-columns="columns"
              :config="config"
            />
          </template>
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
import Visualizations from '../commons/Visualizations.vue';
import CardVisualization from '../../layouts/CardVisualization.vue';

export default {
  name: "VisualizationsGrid",
  components: {
    CardVisualization,
    Visualizations
  },
  props: {
    publicVisualizations: {
      type: Array,
      default: () => []
    }
  }
};
</script>
