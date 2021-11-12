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
import { convertToCSV } from "./../../lib/helpers";
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
      this.removeAllIcons();
    },
    async getDataFromVisualizations(data) {
      const queryPromises = new Map();
      const visualizations = data.map(x => {
        const {
          attributes: {
            query_id,
            dataset_id,
            user_id,
            sql = "",
            spec = {},
            name = "",
            privacy_status = "open"
          } = {},
          id
        } = x;

        // only store new (different) queries (promises)
        if (!queryPromises.has(query_id || sql)) {
          queryPromises.set(
            query_id || sql,
            query_id ? this.getQuery(query_id) : this.getData({ sql })
          );
        }

        //Filter by id to get the slug and the columns.
        const [{ attributes: { columns, slug: slugDataset } }] = this.listDatasets.filter(({ id }) => id == dataset_id)

        return {
          config: spec,
          dataset_id,
          columns,
          slug: slugDataset,
          name,
          privacy_status,
          query_id,
          id,
          user_id,
          sql
        };
      });

      // wait for queries to be solved
      const responses = await Promise.all(
        [...queryPromises.values()].map(x => x.catch(e => e.response))
      );

      [...queryPromises].forEach((item, i) => {
        // ignore the null, they're comes from error catch
        if (responses[i].status !== 200) {
          return queryPromises.delete(item[0]);
        }

        const { data } = responses[i];
        // in the map, replace each promise with its respective response (formatting the results)
        return queryPromises.set(
          item[0],
          typeof data === "object" ? convertToCSV(data.data) : data
        );
      });

      // finally update all existing visualizations with the properly results
      // remove those visualizations whose data is erroneus
      return visualizations.reduce((acc, x) => {
        const k = x.query_id || x.sql;
        if (queryPromises.has(k))
          acc.push({ ...x, items: queryPromises.get(k) });
        return acc;
      }, []);
    },
    removeAllIcons() {
      /*Method to remove the config icon for all visualizations, we need to wait to load both lists when they are loaded, we select alls visualizations, and iterate over them with a loop to remove every icon.*/
      this.$nextTick(() => {
        let vizList = document.querySelectorAll("perspective-viewer");
        for (let index = 0; index < vizList.length; index++) {
          vizList[index].shadowRoot.querySelector(
            "div#config_button"
          ).style.display = "none";
        }
      });
    }
  }
};
</script>
