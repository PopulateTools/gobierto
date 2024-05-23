<template>
  <div>
    <template v-if="isUserLogged">
      <Dropdown @is-content-visible="showPrivateVis = !showPrivateVis">
        <template v-slot:trigger>
          <h3 class="gobierto-data-visualization--h3">
            <Caret :rotate="showPrivateVis" />

            {{ labelVisPrivate }}
            ({{ privateVisualizations.length }})
          </h3>
        </template>
        <div class="gobierto-data-visualization--grid">
          <template v-if="deleteAndReload">
            <Loading />
          </template>
          <template v-else>
            <template v-if="privateVisualizations.length">
              <template v-for="{ config, items, name, privacy_status, id, user_id } in privateVisualizations">
                <div
                  :key="id"
                  class="gobierto-data-visualization--container"
                >
                  <router-link
                    :to="`/datos/${$route.params.id}/v/${id}`"
                    class="gobierto-data-visualizations-name"
                    @click.native="loadViz(name, user_id)"
                  >
                    <CardVisualization>
                      <template v-slot:title>
                        {{ name }}
                      </template>
                      <template v-if="config.base64">
                        <img
                          class="gobierto-data-visualization--image"
                          :src="config.base64"
                        >
                      </template>
                      <template v-else>
                        <Visualizations
                          :items="items"
                          :config="config"
                          :object-columns="objectColumns"
                          :config-map="configMap"
                        />
                      </template>
                    </CardVisualization>
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
        <template v-if="publicVisualizations.length">
          <template v-for="{ config, items, name, id, user_id } in publicVisualizations">
            <div :key="id">
              <router-link
                :to="`/datos/${$route.params.id}/v/${id}`"
                class="gobierto-data-visualizations-name"
                @click.native="loadViz(name, user_id)"
              >
                <CardVisualization>
                  <template v-slot:title>
                    {{ name }}
                  </template>
                  <template v-if="config.base64">
                    <img
                      class="gobierto-data-visualization--image"
                      :src="config.base64"
                    >
                  </template>
                  <template v-else>
                    <Visualizations
                      :items="items"
                      :config="config"
                      :object-columns="objectColumns"
                      :config-map="configMap"
                    />
                  </template>
                </CardVisualization>
              </router-link>
            </div>
          </template>
        </template>

        <template v-else>
          <div>{{ labelVisEmpty }}</div>
        </template>
      </div>
    </Dropdown>
  </div>
</template>
<script>
import { Loading, Dropdown } from '../../../../lib/vue/components';
import Caret from '../commons/Caret.vue';
import Visualizations from '../commons/Visualizations.vue';
import PrivateIcon from '../commons/PrivateIcon.vue';
import { getUserId } from '../../../lib/helpers';
import CardVisualization from '../../layouts/CardVisualization.vue';


export default {
  name: "VisualizationsList",
  components: {
    Visualizations,
    PrivateIcon,
    Dropdown,
    Caret,
    Loading,
    CardVisualization
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
    },
    objectColumns: {
      type: Object,
      default: () => {}
    },
    configMap: {
      type: Object,
      default: () => {}
    },
  },
  data() {
    return {
      labelVisEmpty: I18n.t("gobierto_data.projects.visEmpty") || "",
      labelVisPrivate: I18n.t("gobierto_data.projects.visPrivate") || "",
      labelVisPublic: I18n.t("gobierto_data.projects.visPublic") || "",
      labelDeleteViz: I18n.t("gobierto_data.projects.deleteViz") || "",
      showPrivateVis: true,
      showPublicVis: true,
      deleteAndReload: false,
    };
  },
  watch: {
    isPrivateVizLoading(newValue) {
      if (!newValue) {
        this.deleteAndReload = false
      }
    },
    privateVisualizations(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.deleteAndReload = false
      }
    }
  },
  methods: {
    loadViz(vizName, user) {
      document.getElementById('gobierto-datos-app').scrollIntoView();
      const userId = Number(getUserId())
      this.$emit('changeViz', 1)
      this.$root.$emit('loadVizName', vizName)
      if (userId !== 0 && userId !== user) {
        this.$root.$emit('enabledForkVizButton', true)
      }
    },
    emitDeleteHandlerVisualization(id) {
      this.deleteAndReload = true
      const answerDelete = confirm(this.labelDeleteViz);
      if (answerDelete) {
        this.$emit('emitDelete', id)
      }
    }
  }
};
</script>
