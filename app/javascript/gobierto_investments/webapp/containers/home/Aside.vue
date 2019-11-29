<template>
  <aside class="investments-home-aside--gap">
    <template v-for="filter in filters">
      <div
        :key="filter.key"
        class="investments-home-aside--block"
      >
        <slot :filter="filter" />
      </div>
    </template>
  </aside>
</template>

<script>
export default {
  name: "HomeAside",
  props: {
    filters: {
      type: Array,
      default: () => []
    }
  }
};
</script>
