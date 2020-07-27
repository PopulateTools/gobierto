<template>
  <div class="gobierto_dashboards-search-container">
    <label class="gobierto_dashboards-search-container-label">
      Search subsidies:
    </label>
    <input
      v-model="search"
      type="text"
      placeholder="Search contract"
      class="gobierto_dashboards-search-container-input"
      @input="handlerFilterItems"
      @focus="focusTable"
    >
    <a
      href="#"
      class="gobierto_dashboards-search-btn-clear"
      @click="handlerClearSearch"
    >
      Clear search
    </a>
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
    }
  },
  data() {
    return {
      search: '',
    }
  },
  methods: {
    handlerFilterItems(event) {
      const { target: { value } } = event
      const filterItems = this.data.filter(contract => contract.beneficiary_name.toLowerCase().includes(value.toLowerCase()))
      EventBus.$emit('filtered-items', filterItems)
      EventBus.$emit('filtered-items-subsidies', filterItems)
      EventBus.$emit('update-tab')
    },
    handlerClearSearch() {
      this.search = ''
      EventBus.$emit('filtered-items', this.data)
      EventBus.$emit('filtered-items-subsidies', this.data)
    },
    focusTable() {

    }
  }
}
</script>
