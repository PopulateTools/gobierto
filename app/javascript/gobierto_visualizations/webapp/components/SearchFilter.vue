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
          @input="debouncedFilterItems"
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
import { debounce } from 'lodash';
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
  created() {
    // Debounce the keystroke handler: each call scans the whole dataset, which
    // is costly on large sites. Read the value from the v-model (this.search)
    // rather than the event, since the event fires before the debounced run.
    this.debouncedFilterItems = debounce(this.handlerFilterItems, 250)
  },
  beforeDestroy() {
    this.debouncedFilterItems.cancel()
  },
  methods: {
    handlerFilterItems() {
      const value = this.search
      // Lowercase the query once instead of per row (the filter scans the whole
      // dataset, so on large sites this is tens of thousands of calls saved).
      const query = value.toLowerCase()
      let filterItems
      if (this.searchType === 'Subsidies') {
        filterItems = this.data.filter(contract => contract.beneficiary_name.toLowerCase().includes(query))
      } else {
        filterItems = this.data.filter(contract => contract.assignee.toLowerCase().includes(query) || contract.title.toLowerCase().includes(query) || (contract.document_number || '').toLowerCase().includes(query))
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
