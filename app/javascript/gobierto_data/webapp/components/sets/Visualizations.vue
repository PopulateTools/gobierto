<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <div class="gobierto-data-visualization--grid">
      <template v-if="visualizations.length">
        <template v-for="{ data, config, name } in visualizations">
          <div :key="name">
            <h4>{{ name }}</h4>
            <SQLEditorVisualizations
              :items="data"
              :config="config"
            />
          </div>
        </template>
      </template>

      <template v-else>
        {{ labelVisEmpty }}
      </template>
    </div>
  </div>
</template>
<script>
import { VisualizationFactoryMixin } from "./../../../lib/factories/visualizations";
import { QueriesFactoryMixin } from "./../../../lib/factories/queries";
import { DataFactoryMixin } from "./../../../lib/factories/data";
import SQLEditorVisualizations from "./SQLEditorVisualizations.vue";

export default {
  name: "Visualizations"
}
</script>
