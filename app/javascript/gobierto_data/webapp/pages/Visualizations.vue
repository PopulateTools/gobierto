<template>
  <div class="gobierto-data gobierto-data-landing-visualizations">
    <div class="pure-g gutters m_b_1">
      <div class="pure-u-1 pure-u-lg-4-4 gobierto-data-layout-column">
        <h3 class="gobierto-data-index-title">
          {{ labelVisualizations }}
        </h3>
        <VisualizationsAllList
          v-if="datasetsArray.length && datasetsVisualizations.length"
          :datasets-array="datasetsArray"
          :datasets-attributes="datasetsVisualizations"
        />
      </div>
    </div>
  </div>
</template>
<script>
import VisualizationsAllList from "./../components/landingviz/VisualizationsAllList";
import { CategoriesMixin } from "./../../lib/mixins/categories.mixin";
import { FiltersMixin } from "./../../lib/mixins/filters.mixin";
import { VisualizationFactoryMixin } from "./../../lib/factories/visualizations";

export default {
  name: "Visualizations",
  components: {
    VisualizationsAllList
  },
  mixins: [
    CategoriesMixin,
    FiltersMixin,
    VisualizationFactoryMixin
  ],
  data() {
    return {
      datasetsArray: [],
      datasetsVisualizations: [],
      labelVisualizations: I18n.t("gobierto_data.projects.visualizations") || ""
    }
  },
  created() {
    this.getDataVizs()
  },
  methods: {
    async getDataVizs() {
      const { data: response } = await this.getListVisualizations();
      const { data } = response
      let listVisualizations = data.slice(0, 4)
      let datasets = listVisualizations.map(dataset => dataset.attributes.dataset_id);
      datasets = [ ...new Set(datasets) ];
      this.getDatasets(datasets)
      this.datasetsArray = datasets
    },
    async getDatasets(datasetsID) {
      //Filters dataset which only contains Visualizations
      const datasetsWithVizs = []
      for (let index = 0; index < datasetsID.length; index++) {
        const { data: response } = await this.getVisualizations({
          "filter[dataset_id]": datasetsID[index]
        });
        const { data } = response;

        if (data.length) {
          const { relationships: { dataset: { data: { id } } } } = data[0];
          datasetsWithVizs.push(id);
        }
      }
      this.datasetsVisualizations = this.subsetItems.filter((dataset) => datasetsWithVizs.includes(dataset.id))
    }
  },
};

</script>
