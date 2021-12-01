<template>
  <div class="gobierto-data gobierto-data-landing-visualizations">
    <div class="pure-g gutters m_b_1">
      <template v-if="isLoading">
        <SkeletonSpinner
          height-square="250px"
          squares-rows="2"
          squares="2"
          class="pure-u-1"
        />
      </template>
      <template v-else>
        <div class="pure-u-1 pure-u-lg-4-4 gobierto-data-layout-column">
          <h3 class="gobierto-data-index-title">
            {{ labelVisualizations }}
          </h3>
          <VisualizationsGrid :public-visualizations="publicVisualizations" />
        </div>
      </template>
    </div>
  </div>
</template>
<script>
import VisualizationsGrid from "./../components/landingviz/VisualizationsGrid";
import { VisualizationFactoryMixin } from "./../../lib/factories/visualizations";
import { DataFactoryMixin } from "./../../lib/factories/data";
import { DatasetFactoryMixin } from "./../../lib/factories/datasets";
import { QueriesFactoryMixin } from "./../../lib/factories/queries";
import { SkeletonSpinner } from "lib/vue/components";

export default {
  name: "Visualizations",
  components: {
    VisualizationsGrid,
    SkeletonSpinner
  },
  mixins: [
    DatasetFactoryMixin,
    VisualizationFactoryMixin,
    DataFactoryMixin,
    QueriesFactoryMixin
  ],
  data() {
    return {
      publicVisualizations: [],
      isLoading: true,
      labelVisualizations: I18n.t("gobierto_data.projects.visualizations") || "",
      listDatasets: []
    };
  },
  async created() {
    //Get all the datasets to extract the slug of those that have visualizations.
    const { data: { data } } = await this.getDatasets();
    this.listDatasets = data
    this.getDataVizs();
  },
  methods: {
    async getDataVizs() {
      const {
        data: { data = [] }
      } = await this.getVisualizations({
        "order[updated_at]": "desc"
      });

      this.publicVisualizations = await this.getDataFromVisualizations(data);
      this.isLoading = false;
    },
    async getDataFromVisualizations(data) {
      const visualizations = data.map(x => {
        const {
          attributes: {
            dataset_id,
            spec = {},
            name = "",
          } = {},
          id
        } = x;

        //Filter by id to get the slug and the columns.
        const [{ attributes: { slug: slugDataset } }] = this.listDatasets.filter(({ id }) => id == dataset_id)

        return {
          config: spec,
          dataset_id,
          slug: slugDataset,
          name,
          id
        };
      });

      return visualizations;

    }
  }
};
</script>
