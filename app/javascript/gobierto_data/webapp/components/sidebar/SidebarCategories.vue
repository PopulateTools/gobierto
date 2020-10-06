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
              >{{ checkIfEverythingChecked(filter.isEverythingChecked) }}</a>
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
      labelNone: I18n.t("gobierto_common.vue_components.block_header.none") || '',
      isPermalinkActive: false,
      routeItemsFrequency: [],
      routeItemsCategory: []
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
    },
    isAllChecked() {
      return this.routeItemsFrequency.length !== 0 || this.routeItemsCategory.length !== 0
    }
  },
  created() {
    if (this.$route.params.pathMatch !== undefined) {
      let paramsRouter = this.$route.params.pathMatch.split(':')
      this.isPermalinkActive = true
      this.selectedCheckbox(paramsRouter)
    }
  },
  methods: {
    //TODO temporary functions, waiting for the filter refactor
    sendCheckboxStatus_TEMP({ id, value, filter }) {
      this.$root.$emit("sendCheckbox_TEMP", { id, value, filter })

      this.updateURLwithSelectedCategories(filter)
      this.checkSelectedCheckbox(filter)
    },
    selectAllCheckbox_TEMP({ filter }) {
      filter.options = this.filteredOptions(filter)
      this.$root.$emit("selectAll_TEMP", { filter })

      this.updateURLwithSelectedCategories(filter)
      this.checkSelectedCheckbox(filter)
    },
    filteredOptions(filter) {
      return filter.options.filter(({ counter: element = 0 }) => element > 0 );
    },
    updateURLwithSelectedCategories(values) {
      if (this.$route.name === 'Dataset') {
        // eslint-disable-next-line no-unused-vars
        this.$router.push('/datos/').catch(err => {})
      }

      const { options: optionsChecked } = values
      const { key } = values
      //We filter by selected elements
      const isItemSelected = optionsChecked.filter(({ isOptionChecked, counter }) => isOptionChecked === true && counter > 0)
      //Now we get only the id of them
      const getIdFromItems = [...new Set(isItemSelected.map(({ id }) => id))]

      //Create an array which contains only the id from selected elements
      let routeItems = []
      if (key === 'frequency') {
        this.routeItemsFrequency = this.getElements(getIdFromItems)
        this.routeItemsCategory = this.reFilterElements('category')
      }

      if (key === 'category') {
        this.routeItemsCategory = this.getElements(getIdFromItems)
        this.routeItemsFrequency = this.reFilterElements('frequency')
      }

      //Create an array with all elements
      routeItems = [...this.routeItemsFrequency, ...this.routeItemsCategory]
      //Remove duplicate elements, and remove commas
      routeItems = [...new Set(routeItems)];
      routeItems = routeItems.toString().replace(/,/gi, '')

      //If the user accesses through a permalink we change the route
      let backSlashRoute = this.$route.fullPath === '/datos' ? `${this.$route.path}/terms/` : `${this.$route.path}terms/`
      let urlTerms = this.isPermalinkActive ? `${location.origin}/datos/terms/` : backSlashRoute
      urlTerms = routeItems.length === 0 ? `${this.$route.path}` : urlTerms

      history.pushState(
        {},
        null,
        `${urlTerms}${routeItems}`
      )
    },
    getElements(ids) {
      let list = []
      if (ids.length > 0) {
        for (let index = 0; index < ids.length; index++) {
          let item = `${ids[index]}:`
          list.push(item)
        }
      }
      return list
    },
    reFilterElements(category) {
      let elements = []
      elements = this.filters.filter(({ key }) => key === category)
      const { options } = elements[0]
      const isItemCounter = options.filter(({ isOptionChecked, counter }) => isOptionChecked === true && counter > 0)
      const getIdFromItemsCounter = [...new Set(isItemCounter.map(({ id }) => id))]
      elements = this.getElements(getIdFromItemsCounter)
      return elements
    },
    selectedCheckbox(values) {
      //When the user accesses through a permalink we capture the selected elements, select them and filter the datasets
      const categoriesSelected = values.filter(item => item).map(item => +item);
      for (let item of this.filters) {
        item.options.forEach((d) => {
          if (categoriesSelected.includes(d.id)) {
            d.isOptionChecked = true
          }
        })
        this.$root.$emit("selectCheckboxPermalink_TEMP", item)
      }
    },
    checkSelectedCheckbox() {
      //If all checkbox are unselected update URL and goes to datos
      if (!this.isAllChecked) {
        // eslint-disable-next-line no-unused-vars
        this.$router.push('/datos/').catch(err => {})
      }
    },
    checkIfEverythingChecked(value) {
      return value === true ? this.labelNone : this.labelAll
    }
  }
};
</script>
