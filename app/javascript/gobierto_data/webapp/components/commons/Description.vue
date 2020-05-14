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
        <template
          v-for="(row, i) in numberOfRows"
        >
          <div
            v-for="element in arrayOfObjectsColumns.slice(i * itemsPerRow, (i + 1) * itemsPerRow)"
            :key="Object.keys(element)[0]"
            :title="Object.values(element)[0]"
            class="gobierto-data-columns-icon-description"
          >
            <i
              :class="'fas gobierto-data-columns-icon gobierto-data-columns-icon-' + Object.values(element)[0]"
              style="color: var(--color-base);"
            />
            <span class="gobierto-data-sidebar-datasets-links-columns-text">
              {{ Object.keys(element)[0] }}
            </span>
          </div>
        </template>
      </div>
    </Dropdown>
  </div>
</template>
<script>
import Caret from "./../commons/Caret.vue";
import { Dropdown } from "lib/vue-components";
export default {
  name: 'Description',
  components: {
    Caret,
    Dropdown
  },
  props: {
    arrayColumns: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      itemsPerRow: 5,
      labelDescription: I18n.t("gobierto_data.projects.description") || '',
      showDescription: true,
      arrayOfObjectsColumns: []
    }
  },
  computed: {
    numberOfRows() {
      return Math.ceil(Object.keys(this.arrayOfObjectsColumns).length / this.itemsPerRow);
    }
  },
  created() {
    this.arrayOfObjectsColumns = Object.entries(this.arrayColumns).map(([k, v]) => ({ [k]: v }));
  }
}
</script>
