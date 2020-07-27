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
      @input="HandlerFilterItems"
    >
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
    HandlerFilterItems(event) {
      const { target: { value } } = event
      const filterItems = this.data.filter(contract => contract.beneficiary_name.toLowerCase().includes(value.toLowerCase()))
      EventBus.$emit('filtered-items', filterItems)
      EventBus.$emit('filtered-items-subsidies', filterItems)
    }
  }
}
</script>
