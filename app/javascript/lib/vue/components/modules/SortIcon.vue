<template>
  <i
    v-if="direction"
    :class="`gobierto-table__column-selector__icon fas fa-sort-amount-${icon}`"
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
      return this.direction === "desc" ? "down" : "down-alt"
    }
  }
};
</script>
