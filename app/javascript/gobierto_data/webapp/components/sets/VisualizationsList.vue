<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <template v-if="isUserLogged">
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
          <template v-if="isPrivateVizLoading">
            <Spinner />
          </template>

          <template v-else>
            <template v-if="privateVisualizations.length">
              <template v-for="{ items, queryData, config, name, privacy_status, id, user_id } in privateVisualizations">
                <div
                  :key="name"
                  class="gobierto-data-visualization--container"
                >
                  <router-link
                    :to="`/datos/${$route.params.id}/v/${id}`"
                    class="gobierto-data-visualizations-name"
                    @click.native="loadViz(name, user_id)"
                  >
                    <div class="gobierto-data-visualization--card">
                      <div class="gobierto-data-visualization--aspect-ratio-16-9">
                        <div class="gobierto-data-visualization--content">
                          <h4 class="gobierto-data-visualization--title">
                            {{ name }}
                          </h4>
                          <Visualizations
                            :items="items"
                            :config="config"
                          />
                        </div>
                      </div>
                    </div>
                  </router-link>
                  <div class="gobierto-data-visualization--icons">
                    <PrivateIcon
                      :is-closed="privacy_status === 'closed'"
                    />
                    <i
                      class="fas fa-trash-alt"
                      style="color: var(--color-base); cursor: pointer;"
                      @click.stop="emitDeleteHandlerVisualization(id)"
                    />
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
        <template v-if="isPublicVizLoading">
          <Spinner />
        </template>

        <template v-else>
          <template v-if="publicVisualizations.length">
            <template v-for="{ items, config, name, id, user_id } in publicVisualizations">
              <div :key="name">
                <router-link
                  :to="`/datos/${$route.params.id}/v/${id}`"
                  class="gobierto-data-visualizations-name"
                  @click.native="loadViz(name, user_id)"
                >
                  <div class="gobierto-data-visualization--card">
                    <div class="gobierto-data-visualization--aspect-ratio-16-9">
                      <div class="gobierto-data-visualization--content">
                        <h4 class="gobierto-data-visualization--title">
                          {{ name }}
                        </h4>
                        <Visualizations
                          :items="items"
                          :config="config"
                        />
                      </div>
                    </div>
                  </div>
                </router-link>
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
import { getUserId } from "./../../../lib/helpers";

export default {
  name: "VisualizationsList",
  components: {
    Visualizations,
    Spinner,
    PrivateIcon,
    Dropdown,
    Caret
  },
  props: {
    datasetId: {
      type: Number,
      required: true
    },
    isUserLogged: {
      type: Boolean,
      default: false
    },
    isPrivateVizLoading: {
      type: Boolean,
      default: false
    },
    isPublicVizLoading: {
      type: Boolean,
      default: false
    },
    publicVisualizations: {
      type: Array,
      default: () => []
    },
    privateVisualizations: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelVisEmpty: I18n.t("gobierto_data.projects.visEmpty") || "",
      labelVisPrivate: I18n.t("gobierto_data.projects.visPrivate") || "",
      labelVisPublic: I18n.t("gobierto_data.projects.visPublic") || "",
      showPrivateVis: true,
      showPublicVis: true,
    };
  },
  methods: {
    loadViz(vizName, user) {
      const userId = Number(getUserId())
      this.$emit('changeViz', 1)
      this.$root.$emit('loadVizName', vizName)
      if (userId !== 0 && userId !== user) {
        this.$root.$emit('enabledForkVizButton', true)
      }
    },
    emitDeleteHandlerVisualization(id) {
      this.$emit('emitDelete', id)
    }
  }
};
</script>
