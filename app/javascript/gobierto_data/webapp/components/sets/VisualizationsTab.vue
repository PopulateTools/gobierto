<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <component
      :is="currentVizComponent"
      v-if="privateVisualizations"
      :public-visualizations="publicVisualizations"
      :private-visualizations="privateVisualizations"
      :dataset-id="datasetId"
      :is-user-logged="isUserLogged"
      :items="items"
      :config="config"
      :name="titleViz"
      @changeViz="showVizElement"
    />
  </div>
</template>
<script>

const COMPONENTS = [
  () => import("./VisualizationsList.vue"),
  () => import("./VisualizationsItem.vue")
];

import { VisualizationFactoryMixin } from "./../../../lib/factories/visualizations";
import { QueriesFactoryMixin } from "./../../../lib/factories/queries";
import { DataFactoryMixin } from "./../../../lib/factories/data";
import { getUserId } from "./../../../lib/helpers";

export default {
  name: "VisualizationsTab",
  mixins: [VisualizationFactoryMixin, QueriesFactoryMixin, DataFactoryMixin],
  props: {
    datasetId: {
      type: Number,
      required: true
    },
    isUserLogged: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      currentVizComponent: null,
      publicVisualizations: [],
      privateVisualizations: [],
      items: '',
      titleViz: '',
      activeViz: 0,
      config: {}
    };
  },
  created() {
    this.currentVizComponent = COMPONENTS[this.activeViz];
    this.userId = getUserId();

    // Get all visualizations
    this.getPrivateVisualizations();
    this.getPublicVisualizations();
  },
  methods: {
    showVizElement() {
      this.activeViz = 1
      this.currentVizComponent = COMPONENTS[this.activeViz];
    },
    async getPublicVisualizations() {
      this.isPublicLoading = true

      const { data: response } = await this.getVisualizations({
        "filter[dataset_id]": this.datasetId
      });
      const { data } = response;

      if (data.length) {
        this.publicVisualizations = await this.getDataFromVisualizations(data);
      }

      this.isPublicLoading = false
    },
    async getPrivateVisualizations() {
      this.isPrivateLoading = true

      if (this.userId) {
        const { data: response } = await this.getVisualizations({
          "filter[dataset_id]": this.datasetId,
          "filter[user_id]": this.userId
        });
        const { data } = response;

        if (data.length) {
          this.privateVisualizations = await this.getDataFromVisualizations(
            data
          );
        }
      }

      this.isPrivateLoading = false
    },
    async getDataFromVisualizations(data) {
      const visualizations = [];
      for (let index = 0; index < data.length; index++) {
        const { attributes = {}, id } = data[index];
        const { query_id, spec = {}, name = "", privacy_status = "open" } = attributes;

        let queryData = null;

        if (query_id) {
          // Get my queries, if they're stored
          const { data } = await this.getQuery(query_id);
          queryData = data;
        } else {
          // Otherwise, run the sql
          const { sql } = attributes;
          const { data } = await this.getData({ sql });
          queryData = data;
        }

        // Append the visualization configuration
        const visualization = { queryData, config: spec, name, privacy_status, query_id, id };

        visualizations.push(visualization);

        this.items = queryData
        this.titleViz = name
        this.config = visualization.config
      }

      return visualizations;
    },
    async deleteHandlerVisualization(id) {
      this.deleteVisualization(id)
      this.getPrivateVisualizations()
      this.getPublicVisualizations()
    },
  }
};
</script>
