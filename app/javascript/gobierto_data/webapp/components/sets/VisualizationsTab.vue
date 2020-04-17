<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <template v-if="isUserLoggged">
      <Dropdown @is-content-visible="showPrivateVis = !showPrivateVis">
        <template v-slot:trigger>
          <h3 class="gobierto-data-visualization--h3">
            <Caret :rotate="showPrivateVis" />

            {{ labelVisPrivate }}
            <template v-if="privateVisualizations.length">
              ({{ privateVisualizations.length }})
            </template>
          </h3>
        </template>

        <div class="gobierto-data-visualization--grid">
          <template v-if="isPrivateLoading">
            <Spinner />
          </template>

          <template v-else>
            <template v-if="privateVisualizations.length">
              <template v-for="{ data, config, name, privacy_status } in privateVisualizations">
                <div :key="name">
                  <div class="gobierto-data-visualization--card">
                    <div class="gobierto-data-visualization--aspect-ratio-16-9">
                      <div class="gobierto-data-visualization--content">
                        <h4 class="gobierto-data-visualization--title">
                          {{ privateVisualizations }}
                        </h4>
                        <PrivateIcon
                          :is-closed="privacy_status === 'closed'"
                          class="icons-your-visualizations"
                        />
                        <Visualizations
                          :items="data"
                          :config="config"
                        />
                      </div>
                    </div>
                  </div>
                </div>
              </template>
            </template>

            <template v-else>
              <div>{{ labelVisEmpty }}</div>
            </template>
          </template>
        </div>
      </Dropdown>
    </template>

    <Dropdown @is-content-visible="showPublicVis = !showPublicVis">
      <template v-slot:trigger>
        <h3 class="gobierto-data-visualization--h3">
          <Caret :rotate="showPublicVis" />

          {{ labelVisPublic }}
          <template v-if="publicVisualizations.length">
            ({{ publicVisualizations.length }})
          </template>
        </h3>
      </template>

      <div class="gobierto-data-visualization--grid">
        <template v-if="isPublicLoading">
          <Spinner />
        </template>

        <template v-else>
          <template v-if="publicVisualizations.length">
            <template v-for="{ data, config, name } in publicVisualizations">
              <div :key="name">
                <div class="gobierto-data-visualization--card">
                  <div class="gobierto-data-visualization--aspect-ratio-16-9">
                    <div class="gobierto-data-visualization--content">
                      <h4 class="gobierto-data-visualization--title">
                        {{ name }}
                      </h4>
                      <Visualizations
                        :items="data"
                        :config="config"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </template>
          </template>

          <template v-else>
            <div>{{ labelVisEmpty }}</div>
          </template>
        </template>
      </div>
    </Dropdown>
  </div>
</template>
<script>
import Spinner from "./../commons/Spinner.vue";
import Caret from "./../commons/Caret.vue";
import Visualizations from "./../commons/Visualizations.vue";
import PrivateIcon from './../commons/PrivateIcon.vue';
import { Dropdown } from "lib/vue-components";
import { VisualizationFactoryMixin } from "./../../../lib/factories/visualizations";
import { QueriesFactoryMixin } from "./../../../lib/factories/queries";
import { DataFactoryMixin } from "./../../../lib/factories/data";
import { getUserId } from "./../../../lib/helpers";


export default {
  name: "VisualizationsTab",
  components: {
    Visualizations,
    Spinner,
    PrivateIcon,
    Dropdown,
    Caret
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
      labelVisEmpty: I18n.t("gobierto_data.projects.visEmpty") || "",
      labelVisPrivate: I18n.t("gobierto_data.projects.visPrivate") || "",
      labelVisPublic: I18n.t("gobierto_data.projects.visPublic") || "",
      publicVisualizations: [],
      privateVisualizations: [],
      isUserLoggged: false,
      isPrivateLoading: false,
      isPublicLoading: false,
      showPrivateVis: true,
      showPublicVis: true,
    };
  },
  created() {
    this.userId = getUserId();
    this.isUserLoggged = !!this.userId;

    // Get all visualizations
    this.getPrivateVisualizations();
    this.getPublicVisualizations();
  },
  methods: {
    async getPublicVisualizations() {
      this.isPublicLoading = true

      const { data: response } = await this.getVisualizations({
        "filter[dataset_id]": this.datasetId
      });
      const { data } = response;

      if (data.length) {
        this.publicVisualizations = await this.getDataFromVisualizations(data);
      }

      this.isPublicLoading = false
    },
    async getPrivateVisualizations() {
      this.isPrivateLoading = true

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

      this.isPrivateLoading = false
    },
    async getDataFromVisualizations(data) {
      const visualizations = [];
      for (let index = 0; index < data.length; index++) {
        const { attributes = {} } = data[index];
        const { query_id: id, spec = {}, name = "", privacy_status = "open" } = attributes;

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
        const visualization = { ...queryData, config: spec, name, privacy_status };

        visualizations.push(visualization);
      }

      return visualizations;
    }
  }
};
</script>
