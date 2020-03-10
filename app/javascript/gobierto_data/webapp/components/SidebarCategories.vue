<template>
  <div class="pure-u-1 pure-u-lg-4-4">
    <aside
      v-if="filters[0].count >= 1 || filters[1].count >= 1"
      class="gobierto-data-filters"
    >
      <div
        v-for="filter in filters"
        :key="filter.title"
        :class="!filter.key ? 'gobierto-data-filters-element-no-margin' : ''"
        class="gobierto-data-filters-element"
      >
        <template v-if="filter.type === 'vocabulary_options'">
          <div>
            <BlockHeader
              :title="filter.title"
              :label-alt="filter.isEverythingChecked"
              :class="filter.key ? '' : 'gobierto-filter-rotate-icon'"
              see-link
              @toggle="e => filter.key = !filter.key"
              @select-all="e => selectAllCheckbox({ ...e, filter })"
            />
          </div>
          <Checkbox
            v-for="option in filter.options"
            v-show="filter.key"
            :id="option.id"
            :key="option.id"
            :title="option.title"
            :checked="option.isOptionChecked"
            :counter="option.counter"
            @checkbox-change="e => sendCheckboxStatus({ ...e, filter })"
          />
        </template>
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
