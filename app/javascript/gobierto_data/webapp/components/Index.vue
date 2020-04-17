<template>
  <div>
    <div class="gobierto-data-infolist" />
    <div
      v-for="{
        id,
        attributes: {
          slug,
          name,
          description,
          data_updated_at,
          category: [{ category } = {}] = [],
          frequency: [{ frequency } = {}] = []
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
      labelDownloadData: I18n.t("gobierto_data.projects.downloadData") || ""
    };
  }
};
</script>
