<template>
  <div class="pure-u-1 pure-u-lg-4-4">
    <aside
      v-if="checkFilters"
      class="gobierto-data-filters"
    >
      <div
        v-for="filter in filtersModify"
        :key="filter.title"
        :class="!filter.isToggle ? 'gobierto-data-filters-element-no-margin' : ''"
        class="gobierto-data-filters-element"
      >
        <Dropdown @is-content-visible="filter.isToggle = !filter.isToggle">
          <template v-slot:trigger>
            <!-- <BlockHeader
              :title="filter.title"
              :label-alt="filter.isEverythingChecked"
              :class="filter.isToggle ? '' : 'gobierto-filter-rotate-icon'"
              see-link
              @select-all="e => selectAllCheckbox_TEMP({ ...e, filter })"
            /> -->
            <div class="gobierto-block-header" style="flex: 1;">
              <strong class="gobierto-block-header--title">
                <Caret :rotate="filter.isToggle" />
                {{ filter.title }}</strong>
              <a
                class="gobierto-block-header--link"
                @click.stop="e => selectAllCheckbox_TEMP({ ...e, filter })"
              >{{
                filter.isEverythingChecked ? labelNone : labelAll
              }}</a>
            </div>
          </template>
          <div>
            <Checkbox
              v-for="option in filter.options"
              :id="option.id"
              :key="option.id"
              :title="option.title"
              :checked="option.isOptionChecked"
              :counter="option.counter"
              @checkbox-change="e => sendCheckboxStatus_TEMP({ ...e, filter })"
            />
          </div>
        </Dropdown>
      </div>
    </aside>
  </div>
</template>
<script>
import { BlockHeader, Checkbox, Dropdown } from "lib/vue-components";
import Caret from "./../commons/Caret.vue";
export default {
  name: "SidebarCategories",
  components: {
    BlockHeader,
    Dropdown,
    Caret,
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
      labelCategories: "",
      labelAll: "",
      labelNone: ""
    }
  },
  computed: {
    checkFilters() {
      if (!this.filters.length) return false
      return ((this.filters[0] && (this.filters[0] || {}).count >= 1)
        || (this.filters[1] && (this.filters[1] || {}).count >= 1));
    },
    filtersModify() {
      return this.filters.length ? this.filters.map(d => ({ ...d, isToggle: true })) : []
    }
  },
  created() {
    this.labelSets = I18n.t("gobierto_data.projects.sets")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelCategories = I18n.t("gobierto_data.projects.categories")
    this.labelAll = I18n.t("gobierto_common.vue_components.block_header.all");
    this.labelNone = I18n.t("gobierto_common.vue_components.block_header.none");
  },
  methods: {
    //TODO temporary functions, waiting for the filter refactor
    sendCheckboxStatus_TEMP({ id, value, filter }) {
      this.$root.$emit("sendCheckbox_TEMP", { id, value, filter })
      // eslint-disable-next-line no-unused-vars
      this.$router.push('/datos').catch(err => {})
    },
    selectAllCheckbox_TEMP({ filter }) {
      this.$root.$emit("selectAll_TEMP", { filter })
    }
  }
};
</script>
