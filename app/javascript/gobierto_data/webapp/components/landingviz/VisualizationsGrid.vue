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
        <VisualizationsSlot :name="name">
          <template v-slot:visualization>
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
          </template>
        </VisualizationsSlot>
      </router-link>
    </template>
  </div>
</template>
<script>
import Visualizations from "./../commons/Visualizations.vue";
import VisualizationsSlot from "./../commons/VisualizationsSlot.vue";
export default {
  name: "VisualizationsGrid",
  components: {
    Visualizations,
    VisualizationsSlot
  },
  props: {
    publicVisualizations: {
      type: Array,
      default: () => []
    }
  }
};
</script>
