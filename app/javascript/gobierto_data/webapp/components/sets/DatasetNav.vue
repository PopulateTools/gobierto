<template>
  <nav class="gobierto-data-sets-nav">
    <ul>
      <router-link
        :to="`/datos/${$route.params.id}/${tabs[0]}`"
        :class="{ 'is-active': activeDatasetTab === 0 }"
        tag="li"
        class="gobierto-data-sets-nav--tab"
      >
        <span>{{ labelSummary }}</span>
      </router-link>
      <router-link
        :to="`/datos/${$route.params.id}/${tabs[1]}`"
        :class="{ 'is-active': activeDatasetTab === 1 }"
        tag="li"
        class="gobierto-data-sets-nav--tab"
      >
        <span>{{ labelData }}</span>
      </router-link>
      <router-link
        :to="`/datos/${$route.params.id}/${tabs[2]}`"
        :class="{ 'is-active': activeDatasetTab === 2 }"
        tag="li"
        class="gobierto-data-sets-nav--tab"
      >
        <span>{{ labelQueries }}</span>
      </router-link>
      <router-link
        :to="`/datos/${$route.params.id}/${tabs[3]}`"
        :class="{ 'is-active': activeDatasetTab === 3 }"
        tag="li"
        class="gobierto-data-sets-nav--tab"
      >
        <span>{{ labelVisualizations }}</span>
      </router-link>
      <router-link
        :to="`/datos/${$route.params.id}/${tabs[4]}`"
        :class="{ 'is-active': activeDatasetTab === 4 }"
        tag="li"
        class="gobierto-data-sets-nav--tab"
      >
        <span>{{ labelDownload }}</span>
      </router-link>
      <router-link
        :to="`/datos/${$route.params.id}/${tabs[5]}`"
        :class="{ 'is-active': activeDatasetTab === 5 }"
        tag="li"
        class="gobierto-data-sets-nav--tab"
      >
        <span>{{ 'Mapa' }}</span>
      </router-link>
    </ul>
  </nav>
</template>
<script>
import { tabs } from '../../../lib/router'

export default {
  name: "DatasetNav",
  props: {
    activeDatasetTab: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      labelSummary: I18n.t("gobierto_data.projects.summary") || "",
      labelData: I18n.t("gobierto_data.projects.data") || "",
      labelQueries: I18n.t("gobierto_data.projects.queries") || "",
      labelVisualizations: I18n.t("gobierto_data.projects.visualizations") || "",
      labelDownload: I18n.t("gobierto_data.projects.download") || "",
      tabs
    };
  }
};
</script>
