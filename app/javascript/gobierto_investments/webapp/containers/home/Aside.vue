<template>
  <aside class="investments-home-aside--gap">
    <template v-for="filter in filters">
      <div
        :key="filter.key"
        class="investments-home-aside--block"
      >
        <BlockFilter
          :filter="filter"
          @set-filter="setFilter"
        />
      </div>
    </template>
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
    setFilter(filter, key, values) {
      this.$emit('set-filter', filter, key, values)
    }
  }
};
</script>

