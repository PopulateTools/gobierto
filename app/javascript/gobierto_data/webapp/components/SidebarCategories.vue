<template>
  <div class="pure-u-1 pure-u-lg-4-4">
    <aside class="gobierto-data-filters">
      <div
        v-for="(filter, index) in filters"
        :key="filter.key + index"
        :class="!filter.key ? 'gobierto-data-filters-element-no-margin' : ''"
        class="gobierto-data-filters-element"
      >
        <div>
          <i
            :class="filter.key ? '' : 'rotate-caret'"
            class="fas fa-caret-down sidebar-filter-caret"
            style="color: var(--color-base);"
            @click="filter.key = !filter.key"
          />
          <BlockHeader
            :title="filter.title"
            :label-alt="filter.isEverythingChecked"
            class="gobierto-data-filters-header"
            see-link
            @select-all="e => selectAllCheckbox({ ...e, filter })"
          />
        </div>
        <Checkbox
          v-if="option.counter > 0"
          v-for="option in filter.options"
          v-show="filter.key"
          :id="option.id"
          :key="option.id"
          :title="option.title"
          :checked="option.isOptionChecked"
          :counter="option.counter"
          class="gobierto-data-filters--checkbox"
          @checkbox-change="e => sendCheckboxStatus({ ...e, filter })"
        />
      </div>
    </aside>
  </div>
</template>
<script>
import { BlockHeader, Checkbox } from "lib/vue-components";
export default {
  name: "SidebarCategories",
  components: {
    BlockHeader,
    Checkbox
  },
  props: {
    activeTab: {
      type: Number,
      default: 0
    },
    filters: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelSets: "",
      labelQueries: "",
      labelCategories: ""
    }
  },
  created() {
    this.labelSets = I18n.t("gobierto_data.projects.sets")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelCategories = I18n.t("gobierto_data.projects.categories")
  },
  methods: {
    sendCheckboxStatus({ id, value, filter }) {
      this.$root.$emit("sendCheckbox", { id, value, filter })
    },
    selectAllCheckbox({ filter }) {
      this.$root.$emit("selectAll", { filter })
    }
  }
};
</script>
