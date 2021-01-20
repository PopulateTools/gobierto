<template>
  <div
    v-clickoutside="showModal"
    class="gobierto-table__column-selector"
  >
    <div
      class="gobierto-table__column-selector__trigger"
      data-testid="table-button-modal"
      @click="showColumnsModal = !showColumnsModal"
    >
      <span>{{ labelCustomizeColumns }}</span>
      <i class="gobierto-table__column-selector__icon fas fa-columns" />
    </div>
    <transition name="fade">
      <div
        v-if="showColumnsModal"
        data-testid="table-modal"
        class="gobierto-table__column-selector__content"
      >
        <Checkbox
          v-for="{ name, visibility, id } in columnsArray"
          :id="id"
          :key="id"
          :title="name"
          :checked="visibility"
          @checkbox-change="toggleVisibility"
        />
      </div>
    </transition>
  </div>
</template>

<script>
//TODO&FIX:ME search another way to avoid error's in jest with dynamics import
// import { Checkbox } from "./lib/vue-components"
// import { clickoutside } from "./lib/vue/directives"
import Checkbox from "./Checkbox.vue";
import { clickoutside } from "./../../../lib/vue/directives"
import * as I18n from 'i18n-js'

export default {
  name: "TableColumnsSelector",
  components: {
    Checkbox
  },
  directives: {
    clickoutside
  },
  props: {
    visibilityColumns: {
      type: Array,
      default: () => []
    },
    data: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      showColumnsModal: false,
      labelCustomizeColumns: I18n.t("gobierto_plans.plan_types.show.customize_columns") || '',
      columnsArray: [],
      columns: Object.keys(this.data[0]),
    }
  },
  created() {
    this.getColumns()
  },
  methods: {
    showModal() {
      if (this.showColumnsModal) {
        this.showColumnsModal = false
      }
    },
    toggleVisibility(column) {
      this.$emit('toggle-visibility', column)
    },
    getColumns() {
      this.columnsArray = this.columns.map((column, index) => ({
        name: column,
        visibility: this.visibilityColumns.includes(column),
        id: index
      }))
    },
  }
}
</script>
