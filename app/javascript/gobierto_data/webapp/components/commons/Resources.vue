<template>
  <div class="gobierto-data-summary-resources">
    <h2 class="gobierto-data-tabs-section-title">
      <i class="fas fa-caret-down" />
      {{ labelResources }}
    </h2>
    <div class="gobierto-data-resources-list">
      <ResourcesItem
        v-for="(item, index) in items"
        :key="index"
        :item="item"
        class="gobierto-data-resources-list-element"
      />
    </div>
  </div>
</template>
<script>
import ResourcesItem from "./ResourcesItem.vue";
export default {
  name: "Resources",
  components: {
    ResourcesItem
  },
  props: {
    items: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      labelResources: ''
    }
  },
  created() {
    this.labelResources = I18n.t("gobierto_data.projects.resources")
  }
}
</script>
