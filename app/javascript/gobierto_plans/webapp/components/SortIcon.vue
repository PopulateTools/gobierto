<template>
  <i
    v-if="direction"
    :class="`fas fa-sort-amount-${direction}`"
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
  }
};
</script>
