<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <Button
      :text="labelEdit"
      class="btn-sql-editor btn-sql-revert-query"
      :class="{ 'isDisabled': !isDirty }"
      icon="chart-area"
      background="#fff"
      @click.native="handleClick"
    />
    <div class="gobierto-data-visualization--aspect-ratio-16-9">
      <Visualizations
        ref="viewer"
        :items="items"
        :config="config"
        :object-columns="objectColumns"
        :config-map="configMapZoom"
        @show-saving="handleConfig"
      />
    </div>
  </div>
</template>
<script>
import Visualizations from '../commons/Visualizations.vue';
import Button from '../commons/Button.vue';

export default {
  name: "MapTab",
  components: {
    Visualizations,
    Button
  },
  props: {
    items: {
      type: String,
      default: ""
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
      config: {
        plugin: 'map'
      },
      configMapZoom: { ...this.configMap, zoom: true },
      labelEdit: I18n.t("gobierto_data.projects.edit") || "",
      isDirty: false
    }
  },
  mounted() {
    if (sessionStorage.getItem("map-tab")) {
      this.config = JSON.parse(sessionStorage.getItem("map-tab"))
      sessionStorage.removeItem("map-tab")
    }

    // otherwise, it won't work ¬¬
    setTimeout(() => this.$refs.viewer.toggleConfigPerspective(), 20);
  },
  methods: {
    handleConfig() {
      const config = this.$refs.viewer.getConfig()
      sessionStorage.setItem("map-tab", JSON.stringify(config))

      this.isDirty = true
    },
    handleClick() {
      this.$router.push({ path: `/datos/${this.$route.params.id}/editor` })
    }
  }
};
</script>
