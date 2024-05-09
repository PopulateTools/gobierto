<template>
  <div>
    <Dropdown @is-content-visible="showDescription = !showDescription">
      <template v-slot:trigger>
        <h2 class="gobierto-data-tabs-section-title">
          <Caret :rotate="showDescription" />
          {{ labelDescription }}
        </h2>
      </template>
      <div class="gobierto-data-description">
        <template>
          <div
            v-for="{ column, type } in arrayOfObjectsColumns"
            :key="column"
          >
            <i
              :class="`fas gobierto-data-columns-icon gobierto-data-columns-icon-${type}`"
              style="color: var(--color-base);"
            />
            <span class="gobierto-data-sidebar-datasets-links-columns-text">
              {{ column }}
            </span>
          </div>
        </template>
      </div>
    </Dropdown>
  </div>
</template>
<script>
import Caret from '../commons/Caret.vue';
import { Dropdown } from '../../../../lib/vue/components';

export default {
  name: 'Description',
  components: {
    Caret,
    Dropdown
  },
  props: {
    objectColumns: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      labelDescription: I18n.t("gobierto_data.projects.description") || '',
      showDescription: true,
      arrayOfObjectsColumns: []
    }
  },
  created() {
    this.arrayOfObjectsColumns = Object.entries(this.objectColumns).map(([k, v]) => ({ column: k, type: v }));
  }
}
</script>
