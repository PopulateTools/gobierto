<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <template v-if="isUserLoggged">
      <h3>{{ labelVisPrivate }}</h3>
      <div class="gobierto-data-visualization--grid">
        <template v-if="privateVisualizations.length">
          <template v-for="{ data, config, name } in privateVisualizations">
            <div :key="name">
              <h4>{{ name }}</h4>
              <SQLEditorVisualizations
                :items="data"
                :config="config"
              />
            </div>
          </template>
        </template>

        <template v-else>
          {{ labelVisEmpty }}
        </template>
      </div>
    </template>

    <h3>{{ labelVisPublic }}</h3>
    <div class="gobierto-data-visualization--grid">
      <template v-if="publicVisualizations.length">
        <template v-for="{ data, config, name } in publicVisualizations">
          <div :key="name">
            <h4>{{ name }}</h4>
            <SQLEditorVisualizations
              :items="data"
              :config="config"
            />
          </div>
        </template>
      </template>

      <template v-else>
        {{ labelVisEmpty }}
      </template>
    </div>
  </div>
</template>
<script>
import SQLEditorVisualizations from "./SQLEditorVisualizations.vue";
import { VisualizationFactoryMixin } from "./../../../lib/factories/visualizations";
import { QueriesFactoryMixin } from "./../../../lib/factories/queries";
import { DataFactoryMixin } from "./../../../lib/factories/data";
import { getUserId } from "./../../../lib/helpers";

export default {
  name: "Visualizations",
  components: {
    SQLEditorVisualizations
  },
  mixins: [VisualizationFactoryMixin, QueriesFactoryMixin, DataFactoryMixin],
  props: {
    datasetId: {
      type: Number,
      required: true
    }
  },
  data() {
    return {
      labelVisEmpty: "",
      labelVisPrivate: "",
      labelVisPublic: "",
      publicVisualizations: [],
      privateVisualizations: [],
      isUserLoggged: false
    };
  },
  created() {
    this.labelVisEmpty = I18n.t("gobierto_data.projects.visEmpty");
    this.labelVisPrivate = I18n.t("gobierto_data.projects.visPrivate");
    this.labelVisPublic = I18n.t("gobierto_data.projects.visPublic");

    this.userId = getUserId();
    this.isUserLoggged = !!this.userId;

    // Get all visualizations
    this.getPrivateVisualizations();
    this.getPublicVisualizations();
  },
  methods: {
    async getPublicVisualizations() {
      const { data: response } = await this.getVisualizations({
        "filter[dataset_id]": this.datasetId
      });
      const { data } = response;

      if (data.length) {
        this.publicVisualizations = await this.getDataFromVisualizations(data);
      }
    },
    async getPrivateVisualizations() {
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
    },
    async getDataFromVisualizations(data) {
      const visualizations = [];
      for (let index = 0; index < data.length; index++) {
        const { attributes = {} } = data[index];
        const { query_id: id, spec = {}, name = "" } = attributes;

        let queryData = null;

        if (id) {
          // Get my queries, if they're stored
          const { data } = await this.getQuery(id);
          queryData = data;
        } else {
          // Otherwise, run the sql
          const { sql } = attributes;
          const { data } = await this.getData({ sql });
          queryData = data;
        }

        // Append the visualization configuration
        const visualization = { ...queryData, config: spec, name };

        visualizations.push(visualization);
      }

      return visualizations;
    }
  }
};
</script>
