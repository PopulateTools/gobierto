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
  name: "Visualizations",
  components: {
    SQLEditorVisualizations
  },
  datasetId: {
    type: Number,
    required: true
  },
  mixins: [VisualizationFactoryMixin, QueriesFactoryMixin, DataFactoryMixin],
  data() {
    return {
      visualizations: [],
      labelNoVis: ""
    };
  },
  async created() {
    this.labelVisEmpty = I18n.t("gobierto_data.projects.visEmpty");

    // Get all my visualizations
    const { data: response } = await this.getVisualizations({ 'filter[dataset_id]': this.datasetId });
    const { data } = response;

    if (data.length) {
      for (let index = 0; index < data.length; index++) {
        const { attributes = {} } = data[index];
        const { query_id: id, spec = {}, name = "" } = attributes;

        let queryData = null;

        if (id) {
          // Get my queries, if they're stored
          const { data } = await this.getQuery(id)
          queryData = data
        } else {
          // Otherwise, run the sql
          const { sql } = attributes
          const { data } = await this.getData({ sql })
          queryData = data
        }

        // Append the visualization configuration
        const visualization = { ...queryData, config: spec, name }

        this.visualizations.push(visualization);
      }
    }
  },
};
</script>
