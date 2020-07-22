<template>
  <div class="gobierto-data gobierto-data-landing-visualizations">
    <!-- <VisualizationsHeader /> -->
    <div class="pure-g gutters m_b_1">
      <div class="pure-u-1 pure-u-lg-1-4 gobierto-data-layout-column gobierto-data-layout-sidebar">
        <p>Sidebar Opcional</p>
      </div>

      <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
        <h3 class="gobierto-data-index-title">
          {{ labelVisualizations }}
        </h3>
        <div
          v-for="{
            id,
            attributes
          } in datasetsVisualizations"
          :key="id"
          class="gobierto-data-info-list-element"
        >
          <VisualizationsAllList
            :dataset-id="id"
            :dataset-attributes="attributes"
          />
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import VisualizationsAllList from "./../components/landingviz/VisualizationsAllList";
import VisualizationsHeader from "./../components/landingviz/VisualizationsHeader";
import { CategoriesMixin } from "./../../lib/mixins/categories.mixin";
import { FiltersMixin } from "./../../lib/mixins/filters.mixin";
import { VisualizationFactoryMixin } from "./../../lib/factories/visualizations";

export default {
  name: "Visualizations",
  components: {
    VisualizationsAllList,
    VisualizationsHeader
  },
  mixins: [
    CategoriesMixin,
    FiltersMixin,
    VisualizationFactoryMixin
  ],
  data() {
    return {
      datasetsVisualizations: [],
      labelVisualizations: I18n.t("gobierto_data.projects.visualizations") || "",
    }
  },
  created() {
    this.getDataVizs()
  },
  methods: {
    async getDataVizs() {
      const { data: response } = await this.getListVisualizations();
      const { data: listVisualizations } = response
      const sizeViz = 4
      let datasets = listVisualizations.slice(0, sizeViz).map(dataset => dataset.attributes.dataset_id);
      this.getPublicVisualizations(datasets)
    },
    async getPublicVisualizations(datasetsID) {
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
  }
};

</script>
