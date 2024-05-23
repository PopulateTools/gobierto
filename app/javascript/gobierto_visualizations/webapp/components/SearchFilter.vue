<template>
  <div class="gobierto_visualizations-search-container">
    <div class="gobierto_visualizations-search-container-wrapper-input">
      <div class="search-box">
        <i class="fas fa-search gobierto_visualizations-search-btn-search" />
        <input
          v-model="search"
          type="text"
          :placeholder="labelPlaceholder"
          class="gobierto_visualizations-search-container-input"
          @input="handlerFilterItems"
        >
        <i
          v-if="showClearSearch"
          class="fas fa-times gobierto_visualizations-search-btn-clear"
          @click="handlerClearSearch"
        />
      </div>
    </div>
  </div>
</template>

<script>
import { EventBus } from '../lib/mixins/event_bus';
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
      labelPlaceholder: I18n.t('gobierto_visualizations.visualizations.contracts.search_placeholder')
    }
  },
  computed: {
    showClearSearch() {
      return this.search
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
      EventBus.$emit('update-tab')
    }
  }
}
</script>
