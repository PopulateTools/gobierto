<template>
  <div v-if="datasetsArray.length">
    <template v-if="!isVizsLoading">
      <SkeletonSpinner
        height-square="250px"
        square-rows="2"
        squares="2"
      />
    </template>
    <template v-else>
      <template v-show="showViz">
        <VisualizationsGrid
          :public-visualizations="publicVisualizations"
        />
      </template>
    </template>
  </div>
</template>
<script>
import { VisualizationFactoryMixin } from "./../../../lib/factories/visualizations";
import { DataFactoryMixin } from "./../../../lib/factories/data";
import { QueriesFactoryMixin } from "./../../../lib/factories/queries";
import { convertToCSV } from "./../../../lib/helpers";
import VisualizationsGrid from "./VisualizationsGrid";
import { SkeletonSpinner } from "lib/vue-components";
import { translate } from "lib/shared"
export default {
  name: "VisualizationsAllList",
  components: {
    VisualizationsGrid,
    SkeletonSpinner
  },
  filters: {
    translate
  },
  mixins: [
    VisualizationFactoryMixin,
    DataFactoryMixin,
    QueriesFactoryMixin
  ],
  props: {
    datasetsArray: {
      type: Array,
      default: () => []
    },
    datasetsAttributes: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      publicVisualizations: [],
      showViz: true,
      isVizsLoading: false
    }
  },
  mounted() {
    this.getPublicVisualizations()
  },
  methods: {
    handleToggle() {
      this.showViz = !this.showViz
    },
    async getPublicVisualizations() {
      let allVizs = []
      for (let index = 0; index < this.datasetsArray.length; index++) {
        const { data: response } = await this.getVisualizations({
          "filter[dataset_id]": this.datasetsArray[index]
        });
        const { data } = response;

        if (data.length) {
          this.publicVisualizations = await this.getDataFromVisualizations(data);
          allVizs.push(this.publicVisualizations);
        }
      }

      this.publicVisualizations = allVizs.reduce((flatten, arr) => [...flatten, ...arr])
      this.isVizsLoading = true
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

        let datasetInfo = this.datasetsAttributes.filter((dataset) => dataset.id == dataset_id)

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
  }
};
</script>
