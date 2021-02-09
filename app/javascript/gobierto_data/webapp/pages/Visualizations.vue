<template>
  <div class="gobierto-data gobierto-data-landing-visualizations">
    <div class="pure-g gutters m_b_1">
      <template v-if="!isVizsLoaded">
        <SkeletonSpinner
          height-square="250px"
          square-rows="2"
          squares="2"
        />
      </template>
      <template v-else>
        <div class="pure-u-1 pure-u-lg-4-4 gobierto-data-layout-column">
          <h3 class="gobierto-data-index-title">
            {{ labelVisualizations }}
          </h3>
          <VisualizationsGrid
            v-if="showVizs"
            :public-visualizations="publicVisualizations"
          />
        </div>
      </template>
    </div>
  </div>
</template>
<script>
import VisualizationsGrid from "./../components/landingviz/VisualizationsGrid";
import { CategoriesMixin } from "./../../lib/mixins/categories.mixin";
import { convertToCSV } from "./../../lib/helpers";
import { FiltersMixin } from "./../../lib/mixins/filters.mixin";
import { VisualizationFactoryMixin } from "./../../lib/factories/visualizations";
import { DataFactoryMixin } from "./../../lib/factories/data";
import { QueriesFactoryMixin } from "./../../lib/factories/queries";
import { SkeletonSpinner } from "lib/vue/components";

export default {
  name: "Visualizations",
  components: {
    VisualizationsGrid,
    SkeletonSpinner
  },
  mixins: [
    CategoriesMixin,
    FiltersMixin,
    VisualizationFactoryMixin,
    DataFactoryMixin,
    QueriesFactoryMixin
  ],
  data() {
    return {
      datasetsArray: [],
      datasetsVisualizations: [],
      publicVisualizations: [],
      isVizsLoaded: false,
      labelVisualizations: I18n.t("gobierto_data.projects.visualizations") || ""
    }
  },
  computed: {
    showVizs() {
      return this.datasetsArray.length && this.datasetsVisualizations.length
    }
  },
  created() {
    this.getDataVizs()
  },
  methods: {
    async getDataVizs() {
      const { data: response } = await this.getVisualizations({
        "order[updated_at]": "desc"
      });
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
          "order[updated_at]": "desc",
          "filter[dataset_id]": datasetsID[index]
        });
        const { data } = response;

        if (data.length) {
          const { relationships: { dataset: { data: { id } } } } = data[0];
          datasetsWithVizs.push(id);
        }
      }
      this.datasetsVisualizations = this.subsetItems.filter((dataset) => datasetsWithVizs.includes(dataset.id))
      this.getPublicVisualizations()
    },
    async getPublicVisualizations() {
      let allVizs = []
      for (let index = 0; index < this.datasetsArray.length; index++) {
        const { data: response } = await this.getVisualizations({
          "order[updated_at]": "desc",
          "filter[dataset_id]": this.datasetsArray[index]
        });
        const { data } = response;

        if (data.length) {
          this.publicVisualizations = await this.getDataFromVisualizations(data);
          allVizs.push(this.publicVisualizations);
        }
      }

      this.publicVisualizations = allVizs.flat()
      this.isVizsLoaded = true
      this.removeAllIcons()
    },
    async getDataFromVisualizations(data) {
      const visualizations = [];
      for (let index = 0; index < data.length; index++) {
        const { attributes = {}, id } = data[index];
        const { query_id, user_id, sql = "", spec = {}, name = "", privacy_status = "open", dataset_id } = attributes;

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

        let items = ''
        if (typeof(queryData) === 'object') {
          items = convertToCSV(queryData.data)
        } else {
          items = queryData
        }

        let datasetInfo = this.datasetsVisualizations.filter((dataset) => dataset.id == dataset_id)

        const [{ attributes: { columns, slug, name: datasetName } }] = datasetInfo

        // Append the visualization configuration
        const visualization = { items, columns, slug, datasetName, config: spec, name, privacy_status, query_id, id, user_id, sql, dataset_id };

        visualizations.push(visualization);
      }

      return visualizations;
    },
    removeAllIcons() {
      /*Method to remove the config icon for all visualizations, we need to wait to load both lists when they are loaded, we select alls visualizations, and iterate over them with a loop to remove every icon.*/
      this.$nextTick(() => {
        let vizList = document.querySelectorAll("perspective-viewer");
        for (let index = 0; index < vizList.length; index++) {
          vizList[index].shadowRoot.querySelector("div#config_button").style.display = "none";
        }
      })
    }
  },
};

</script>
