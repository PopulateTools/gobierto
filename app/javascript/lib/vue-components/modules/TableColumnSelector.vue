<template>
  <div
    v-clickoutside="showModal"
    class="gobierto-table__column-selector"
  >
    <div
      class="gobierto-table__column-selector__trigger"
      @click="showColumnsModal = !showColumnsModal"
    >
      <span>{{ labelCustomizeColumns }}</span>
      <i class="gobierto-table__column-selector__icon fas fa-columns" />
    </div>
    <transition name="fade">
      <div
        v-if="showColumnsModal"
        class="gobierto-table__column-selector__content"
      >
        <Checkbox
          v-for="[id, { name, visibility }] in columns"
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
    columns: {
      type: Array,
      default: () => []
    },
  },
  data() {
    return {
      showColumnsModal: false,
      labelCustomizeColumns: I18n.t("gobierto_plans.plan_types.show.customize_columns") || ''
    }
  },
  methods: {
    showModal() {
      if (this.showColumnsModal) {
        this.showColumnsModal = false
      }
    },
    toggleVisibility(column) {
      this.$emit('toggle-visibility', column)
    }
  }
}
</script>
