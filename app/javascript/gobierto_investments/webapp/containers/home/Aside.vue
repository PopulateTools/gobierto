<template>
  <aside class="investments-home-aside--gap">
    <div
      v-for="filter in filters"
      :key="filter.key"
      class="investments-home-aside--block"
    >
      <BlockFilter
        :filter="filter"
        @set-filter="setFilter"
      />
    </div>
  </aside>
</template>

<script>
import BlockFilter from "../../components/BlockFilter.vue";

export default {
  name: "HomeAside",
  components: {
    BlockFilter
  },
  props: {
    filters: {
      type: Array,
      default: () => []
    }
  },
  methods: {
    setFilter(filter) {
      this.$emit('set-filter', filter)
    }
  }
};
</script>

