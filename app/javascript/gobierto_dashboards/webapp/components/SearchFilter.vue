<template>
  <div class="gobierto_dashboards-search-container">
    <label class="gobierto_dashboards-search-container-label">
      {{ labelSearch }}:
    </label>
    <div class="gobierto_dashboards-search-container-wrapper-input">
      <div class="search-box">
        <i class="fas fa-search gobierto_dashboards-search-btn-search" />
        <input
          v-model="search"
          type="text"
          :placeholder="labelPlaceholder"
          class="gobierto_dashboards-search-container-input"
          @input="handlerFilterItems"
        >
        <i
          class="fas fa-times gobierto_dashboards-search-btn-clear"
          @click="handlerClearSearch"
        />
      </div>
    </div>
  </div>
</template>

<script>
import { EventBus } from "../mixins/event_bus";
export default {
  name: 'SearchFilter',
  props: {
    data: {
      type: Array,
      default: () => []
    },
    searchType: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      search: '',
      labelSearch: I18n.t('gobierto_dashboards.dashboards.contracts.search'),
      labelPlaceholder: I18n.t('gobierto_dashboards.dashboards.contracts.search_placeholder')
    }
  },
  methods: {
    handlerFilterItems(event) {
      const { target: { value } } = event
      let filterItems
      if (this.searchType === 'Subsidies') {
        filterItems = this.data.filter(contract => contract.beneficiary_name.toLowerCase().includes(value.toLowerCase()))
      } else {
        filterItems = this.data.filter(contract => contract.assignee.toLowerCase().includes(value.toLowerCase()) || contract.title.toLowerCase().includes(value.toLowerCase()))
      }

      EventBus.$emit('filtered-items', value)
      EventBus.$emit('filtered-items-grouped', filterItems, value)
      EventBus.$emit('update-tab')
    },
    handlerClearSearch() {
      this.search = ''
      EventBus.$emit('filtered-items', this.search)
      EventBus.$emit('filtered-items-grouped', this.data)
    }
  }
}
</script>
