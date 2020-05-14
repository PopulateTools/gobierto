<template>
  <div v-if="allDatasets">
    <h3 class="gobierto-data-index-title">
      {{ labelDataset }}
    </h3>
    <div
      v-for="{
        id,
        attributes: {
          slug,
          name,
          description,
          data_updated_at,
          category: [{ name_translations: category } = {}] = [],
          frequency: [{ name_translations: frequency } = {}] = [],
        }
      } in allDatasets"
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
        :category-dataset="category | translate"
        :frequency-dataset="frequency | translate"
        :date-updated="data_updated_at"
      />
    </div>
  </div>
</template>
<script>
import { VueFiltersMixin } from "lib/shared";
import Info from "./commons/Info.vue";


export default {
  name: "Index",
  components: {
    Info
  },
  mixins: [VueFiltersMixin],
  props: {
    allDatasets: {
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
      labelDataset: I18n.t("gobierto_data.projects.dataset") || "",
    };
  },
  created() {
    this.injectRouter()
  },
  methods: {
    injectRouter() {
      const topMenu = document.getElementById('gobierto-data-top-menu')
      topMenu.addEventListener('click', (e) => {
        e.preventDefault()
        // eslint-disable-next-line no-unused-vars
        this.$router.push('/datos').catch(err => {})
      })
    }
  }
};
</script>
