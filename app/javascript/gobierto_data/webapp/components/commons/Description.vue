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
          v-for="row in numberOfRows"
        >
          <div
            v-for="col in itemsPerRow"
          >
            {{ arrayColumns }}
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
      itemsPerRow: 6,
      labelDescription: I18n.t("gobierto_data.projects.description") || '',
      showDescription: true
    }
  },
  computed: {
    numberOfRows() {
      return Math.ceil(Object.keys(this.arrayColumns).length / this.itemsPerRow);
    }
  },
  created() {
    const peopleArray = Object.keys(this.arrayColumns).map(i => this.arrayColumns[i])
    console.log("created -> peopleArray", peopleArray)
  },
}
</script>
