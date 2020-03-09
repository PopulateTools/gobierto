<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <template v-if="visualizations.length">
      <template v-for="{ data, links, config } in visualizations">
        <SQLEditorVisualizations
          :key="links.self"
          :items="data"
          :config="config"
        />
      </template>
    </template>

    <template v-else>
      {{ labelVisEmpty }}
    </template>
  </div>
</template>

<script>
import { VisualizationFactoryMixin } from "./../../../lib/visualizations";
import { QueriesFactoryMixin } from "./../../../lib/queries";
import SQLEditorVisualizations from "./SQLEditorVisualizations.vue";

export default {
  name: "Visualizations",
  components: {
    SQLEditorVisualizations
  },
  mixins: [VisualizationFactoryMixin, QueriesFactoryMixin],
  data() {
    return {
      visualizations: [],
      labelNoVis: ""
    };
  },
  async created() {
    this.labelVisEmpty = I18n.t("gobierto_data.projects.visEmpty");

    // Get all my visualizations
    const { data: response } = await this.getVisualizations();
    const { data } = response;

    if (data.length) {
      for (let index = 0; index < data.length; index++) {
        const { attributes } = data[index];
        const { query_id: id, spec } = attributes;

        // Get my queries, if they're stored
        const { data: queryData } = await this.getQuery(id)

        // Append the visualization configuration
        const visualization = { ...queryData, config: spec }

        this.visualizations.push(visualization);
      }
    }
  }
};
</script>
