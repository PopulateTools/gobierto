<template>
  <div class="gobierto-data gobierto-data-landing-visualizations">
    <VisualizationsHeader />
    <div
      v-for="{
        id,
        attributes: {
          slug,
          name,
          description
        }
      } in datasetsVisualizations"
      :key="id"
      class="gobierto-data-info-list-element"
    >
      <VisualizationsAllList
        :dataset-id="id"
        :slug="slug"
        :name="name"
        :description="description"
      />
    </div>
  </div>
</template>
<script>
import VisualizationsAllList from "./../components/landingviz/VisualizationsAllList";
import VisualizationsHeader from "./../components/landingviz/VisualizationsHeader";
import { CategoriesMixin } from "./../../lib/mixins/categories.mixin";
import { FiltersMixin } from "./../../lib/mixins/filters.mixin";
import { VisualizationFactoryMixin } from "./../../lib/factories/visualizations";
import { SkeletonSpinner } from "lib/vue-components";

export default {
  name: "Visualizations",
  components: {
    VisualizationsAllList,
    VisualizationsHeader,
    SkeletonSpinner
  },
  mixins: [
    CategoriesMixin,
    FiltersMixin,
    VisualizationFactoryMixin
  ],
  data() {
    return {
      datasetsVisualizations: []
    }
  },
  created() {
    this.getDataVizs()
  },
  methods: {
    async getDataVizs() {
      await this.getItems()
      let datasetsID = this.subsetItems.map(dataset => dataset.id);
      this.getPublicVisualizations(datasetsID)
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
