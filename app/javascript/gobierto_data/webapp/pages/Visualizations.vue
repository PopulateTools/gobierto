<template>
  <div class="gobierto-data gobierto-data-landing-visualizations">
    <div class="block">
      <div class="pure-g header_block_inline">
        <div class="pure-u-1 pure-u-md-12-24">
          <div class="inline_header">
            <h2 class="with_description p_h_r_1">
              {{ labelVisualizations }}
            </h2>
          </div>
          <p>
            {{ labelTextVisualizations }}
          </p>
        </div>
      </div>
    </div>
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
import { CategoriesMixin } from "./../../lib/mixins/categories.mixin";
import { FiltersMixin } from "./../../lib/mixins/filters.mixin";
import { VisualizationFactoryMixin } from "./../../lib/factories/visualizations";
import VisualizationsAllList from "./../components/landingviz/VisualizationsAllList";

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
      labelVisualizations: I18n.t("gobierto_data.projects.visualizations") || "",
      labelTextVisualizations: I18n.t("gobierto_data.layouts.visualizations") || "",
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

        if (data[0] !== undefined) {
          const { relationships: { dataset: { data: { id } } } } = data[0];
          datasetsWithVizs.push(id);
        }
      }
      this.datasetsVisualizations = this.subsetItems.filter((dataset) => datasetsWithVizs.includes(dataset.id))
    }
  }
};

</script>
