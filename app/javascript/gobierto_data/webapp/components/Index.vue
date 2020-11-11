<template>
  <div v-if="datasets.length">
    <h3 class="gobierto-data-index-title">
      {{ labelDatasetUpdated }}
    </h3>
    <div
      v-for="{
        id,
        slug,
        name,
        description,
        data_updated_at,
        category,
        frequency,
      } in datasets"
      :key="id"
      class="gobierto-data-info-list-element"
    >
      <router-link
        :to="{ path:`/datos/${slug}`, params: { activeSidebarTab: 1 }}"
        class="gobierto-data-title-dataset gobierto-data-title-dataset-big"
      >
        {{ name }}
      </router-link>

      <Info
        :description-dataset="description"
        :category-dataset="category"
        :frequency-dataset="frequency"
        :date-updated="data_updated_at"
      />
    </div>
  </div>
</template>
<script>
import Info from "./commons/Info.vue";

export default {
  name: "Index",
  components: {
    Info
  },
  props: {
    datasets: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelUpdated: I18n.t("gobierto_data.projects.updated") || "",
      labelFrequency: I18n.t("gobierto_data.projects.frequency") || "",
      labelSubject: I18n.t("gobierto_data.projects.subject") || "",
      labelDownloadData: I18n.t("gobierto_data.projects.downloadData") || "",
      labelDatasetUpdated: I18n.t("gobierto_data.projects.datasetUpdated") || "",
    };
  },
  created() {
    this.injectRouter()
  },
  methods: {
    injectRouter() {
      //REVIEW: Inject a vue router to element outside VUE, be careful
      const topMenu = document.getElementById('gobierto-data-top-menu')
      topMenu.addEventListener('click', (e) => {
        e.preventDefault()
        // eslint-disable-next-line no-unused-vars
        this.$router.push('/datos/').catch(err => {})
      })
    }
  }
};
</script>
