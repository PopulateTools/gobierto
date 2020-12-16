<template>
  <router-view :json="json" />
</template>

<script>
export default {
  name: "PlanB",
  props: {
    json: {
      type: Array,
      default: () => []
    },
    options: {
      type: Object,
      default: () => {}
    }
  }
};
</script>
