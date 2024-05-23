<template>
  <div
    v-if="resourcesList.length"
    class="gobierto-data-summary-resources"
  >
    <Dropdown @is-content-visible="showResources = !showResources">
      <template v-slot:trigger>
        <h2 class="gobierto-data-tabs-section-title">
          <Caret :rotate="showResources" />
          {{ labelResources }}
        </h2>
      </template>
      <div class="gobierto-data-resources-list">
        <ResourcesItem
          v-if="showResources"
          :resources-list="resourcesList"
          class="gobierto-data-resources-list-element"
        />
      </div>
    </Dropdown>
  </div>
</template>
<script>
import ResourcesItem from './ResourcesItem.vue';
import Caret from '../commons/Caret.vue';
import { Dropdown } from '../../../../lib/vue/components';

export default {
  name: "Resources",
  components: {
    ResourcesItem,
    Caret,
    Dropdown
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
