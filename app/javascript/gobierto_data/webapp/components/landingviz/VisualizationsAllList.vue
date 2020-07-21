<template>
  <div v-if="datasetId">
    <template v-if="!isVizsLoading">
      <SkeletonSpinner
        height-square="250px"
        square-rows="2"
        squares="2"
      />
    </template>
    <template v-else>
      <Caret
        :rotate="showViz"
        @click.native="handleToggle"
      />
      <router-link
        :to="{ path:`/datos/${slug}`, params: { activeSidebarTab: 1 }}"
        class="gobierto-data-title-dataset gobierto-data-title-dataset-big"
      >
        {{ name }}
      </router-link>
      <div v-show="showViz">
        <Info
          :description-dataset="description"
        />
        <VisualizationsGrid
          v-if="publicVisualizations"
          :public-visualizations="publicVisualizations"
          :slug="slug"
        />
      </div>
    </template>
  </div>
</template>
<script>
import { VisualizationFactoryMixin } from "./../../../lib/factories/visualizations";
import { DataFactoryMixin } from "./../../../lib/factories/data";
import { QueriesFactoryMixin } from "./../../../lib/factories/queries";
import { convertToCSV } from "./../../../lib/helpers";
import VisualizationsGrid from "./VisualizationsGrid";
import Info from "./../commons/Info.vue";
import Caret from "./../commons/Caret";
import { SkeletonSpinner } from "lib/vue-components";
export default {
  name: "VisualizationsAllList",
  components: {
    VisualizationsGrid,
    Caret,
    Info,
    SkeletonSpinner
  },
  mixins: [
    VisualizationFactoryMixin,
    DataFactoryMixin,
    QueriesFactoryMixin
  ],
  props: {
    datasetId: {
      type: String,
      default: ''
    },
    slug: {
      type: String,
      default: ''
    },
    name: {
      type: String,
      default: ''
    },
    description: {
      type: String,
      default: ''
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
      const { data: response } = await this.getVisualizations({
        "filter[dataset_id]": this.datasetId
      });
      const { data } = response;

      if (data.length) {
        this.publicVisualizations = await this.getDataFromVisualizations(data);
      }
      this.isVizsLoading = true
      this.removeAllIcons()
    },
    async getDataFromVisualizations(data) {
      const visualizations = [];
      for (let index = 0; index < data.length; index++) {
        const { attributes = {}, id } = data[index];
        const { query_id, user_id, sql = "", spec = {}, name = "", privacy_status = "open" } = attributes;

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

        // Append the visualization configuration
        const visualization = { items, config: spec, name, privacy_status, query_id, id, user_id, sql };

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
