<template>
  <div
    v-clickoutside="closeModal"
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
          v-for="[id, { name, visibility } ] in columns"
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
import { Checkbox } from '../../../../lib/vue/components';
import { clickoutside } from '../../../../lib/vue/directives'

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
      type: Map,
      default: () => new Map()
    }
  },
  data() {
    return {
      showColumnsModal: false,
      labelCustomizeColumns: I18n.t("gobierto_common.vue_components.table.customize_columns") || ''
    }
  },
  methods: {
    closeModal() {
      this.showColumnsModal = false
    },
    toggleVisibility({ id, value }) {
      this.columns.set(id, { ...this.columns.get(id), visibility: value });
      this.$emit('visible-columns', this.columns)
    },
  }
}
</script>
