<template>
  <div
    v-clickoutside="showModal"
    class="planification-table__column-selector"
  >
    <div
      class="planification-table__column-selector__trigger"
      @click="showColumnsModal = !showColumnsModal"
    >
      <span>{{ labelCustomizeColumns }}</span>
      <i class="planification-table__column-selector__icon fas fa-columns" />
    </div>
    <transition name="fade">
      <div
        v-if="showColumnsModal"
        class="planification-table__column-selector__content"
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
import { NamesMixin } from '../lib/mixins/names';
import { Checkbox } from '../../../lib/vue/components';
import { clickoutside } from '../../../lib/vue/directives'

export default {
  name: "TableColumnsSelector",
  components: {
    Checkbox
  },
  directives: {
    clickoutside
  },
  mixins: [NamesMixin],
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
