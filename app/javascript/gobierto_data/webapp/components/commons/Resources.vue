<template>
  <div
    v-if="resourcesList.length > 0"
    class="gobierto-data-summary-resources"
  >
    <h2
      class="gobierto-data-tabs-section-title"
      @click="showResources = !showResources"
    >
      <Caret :rotate="showResources" />
      {{ labelResources }}
    </h2>
    <div class="gobierto-data-resources-list">
      <ResourcesItem
        v-if="showResources"
        :resources-list="resourcesList"
        class="gobierto-data-resources-list-element"
      />
    </div>
  </div>
</template>
<script>
import ResourcesItem from "./ResourcesItem.vue";
import Caret from "./../commons/Caret.vue";
export default {
  name: "Resources",
  components: {
    ResourcesItem,
    Caret
  },
  props: {
    resourcesList: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelResources: I18n.t("gobierto_data.projects.resources") || '',
      showResources: true
    }
  }
}
</script>
