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
            <!-- FIXME: remove inline styles in the next filters refactor -->
            <div
              class="gobierto-block-header"
              style="flex: 1;"
            >
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
              v-for="{ id, title, isOptionChecked, counter } in filteredOptions(filter)"
              :id="id"
              :key="id"
              :title="title"
              :checked="isOptionChecked"
              :counter="counter"
              @checkbox-change="e => sendCheckboxStatus_TEMP({ ...e, filter })"
            />
          </div>
        </Dropdown>
      </div>
    </aside>
  </div>
</template>
<script>
import { Checkbox, Dropdown } from "lib/vue-components";
import Caret from "./../commons/Caret.vue";
export default {
  name: "SidebarCategories",
  components: {
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
    },
    items: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelSets: I18n.t("gobierto_data.projects.sets") || '',
      labelQueries: I18n.t("gobierto_data.projects.queries") || '',
      labelCategories: I18n.t("gobierto_data.projects.categories") || '',
      labelAll: I18n.t("gobierto_common.vue_components.block_header.all") || '',
      labelNone: I18n.t("gobierto_common.vue_components.block_header.none") || ''
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
    if (this.$route.params.pathMatch !== undefined) {
      let paramsRouter = this.$route.params.pathMatch.split(':')
      this.selectedCheckbox(paramsRouter)
    }
  },
  methods: {
    //TODO temporary functions, waiting for the filter refactor
    sendCheckboxStatus_TEMP({ id, value, filter }) {
      this.$root.$emit("sendCheckbox_TEMP", { id, value, filter })
      // eslint-disable-next-line no-unused-vars
      this.$router.push('/datos/').catch(err => {})
      const { key } = filter
      if (key === 'category') {
        this.updateURLwithCategoriesSelected(filter)
      }
    },
    selectAllCheckbox_TEMP({ filter }) {
      this.$root.$emit("selectAll_TEMP", { filter })
    },
    filteredOptions(filter) {
      return filter.options.filter(({ counter: element = 0 }) => element > 0 );
    },
    updateURLwithCategoriesSelected(values) {
      const { options: optionsChecked } = values
      const isItemSelected = optionsChecked.filter(({ isOptionChecked }) => isOptionChecked === true)
      const getIdFromItems = [...new Set(isItemSelected.map(({ id }) => id))]
      let routeItems = []
      for (let index = 0; index < getIdFromItems.length - 1; index++) {
        let item = `${getIdFromItems[index]}:`
        routeItems.push(item)
      }
      routeItems = routeItems.toString().replace(/,/gi, '');
       history.pushState(
         {},
         null,
         `${this.$route.path}terms/${routeItems}`
       )
    },
    selectedCheckbox(values) {
      const categoriesSelected = values.filter(item => item).map(item => +item);
      const categories = this.filters.filter(({ key }) => key === 'category')
      const filterCategories = categories.map((element) => {
        return { ...element, options: element.options.filter((option) => categoriesSelected.includes(option.id)) }
      })

      const [{ options: [{ id }] }] = filterCategories
      const value = true
      this.$nextTick(() => {
        this.$root.$emit("sendCheckbox_TEMP", { id, value, filterCategories })
      })
    }
  }
};
</script>
