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
          v-for="(row, i, key) in numberOfRows"
        >
          <div
            v-for="(element) in arrayOfObjectsColumns.slice(i * itemsPerRow, (i + 1) * itemsPerRow)"
            :key="key"
          >
            <i
              :class="'fas gobierto-data-columns-icon-' + Object.values(element)[0]"
              style="color: var(--color-base)"
            />
            <span>
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
    },
    chooseIcon(value) {
      console.log("chooseIcon -> value", value)
      if (this.arrayOfObjectsColumns === 'string') {
        return 'fas fa-calendar'
      }
      return "fas fa-caret-up"
    }

  },
  created() {
    this.arrayOfObjectsColumns = Object.entries(this.arrayColumns).map(([k, v]) => ({ [k]: v }));
  },
  methods: {
    // chooseIcon(icon) {
    //   const valueIcon = Object.values(icon)
    //   const iconText = ['jsonb', 'string','text']
    //   const iconDate = ['time', 'date', 'datetime', 'timestamp', 'timestampz']
    //   const iconPound = ['boolean', 'decimal', 'hstore', 'integer']
    //   if (iconText.every(element => valueIcon[0].includes(element))) {
    //     console.log('text')
    //   }

    //   if (iconDate.every(element => valueIcon[0].includes(element))) {
    //     console.log('calendar')
    //     return 'fas fa-calendar'
    //   }

    //   if (iconPound.every(element => valueIcon[0].includes(element))) {
    //     return 'fas fa-caret-up'
    //   }


    // }
  }
}
</script>
