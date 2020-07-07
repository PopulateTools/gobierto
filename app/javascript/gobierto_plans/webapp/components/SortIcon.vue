<template>
  <i
    v-if="direction"
    :class="`sort-icon fas fa-sort-amount-${icon}`"
  />
</template>

<script>
export default {
  name: "SortIcon",
  props: {
    direction: {
      type: String,
      default: null
    }
  },
  computed: {
    icon() {
      return this.direction === 'down' ? 'down' : 'down-alt'
    }
  }
};
</script>
