<template>
  <nav class="gobierto-data-sets-nav">
    <ul>
      <template v-for="({ path, label }, i) in routes">
        <router-link
          :key="path"
          :to="path"
          :class="{ 'is-active': activeDatasetTab === i }"
          tag="li"
          class="gobierto-data-sets-nav--tab"
        >
          <span>{{ label }}</span>
        </router-link>
      </template>
    </ul>
  </nav>
</template>
<script>
const LABELS = {
  'resumen': I18n.t("gobierto_data.projects.summary") || "",
  'editor': I18n.t("gobierto_data.projects.data") || "",
  'consultas': I18n.t("gobierto_data.projects.queries") || "",
  'visualizaciones': I18n.t("gobierto_data.projects.visualizations") || "",
  'descarga': I18n.t("gobierto_data.projects.download") || "",
  'mapa': I18n.t("gobierto_data.projects.map") || ""
}

export default {
  name: "DatasetNav",
  props: {
    activeDatasetTab: {
      type: Number,
      default: 0
    },
    tabs: {
      type: Array,
      default: () => []
    }
  },
  computed: {
    routes() {
      return this.tabs.map(tab => ({
        path: `/datos/${this.$route.params.id}/${tab}`,
        label: LABELS[tab]
      }))
    }
  }
};
</script>
