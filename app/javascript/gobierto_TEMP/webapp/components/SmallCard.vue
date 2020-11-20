<template>
  <div
    class="dashboards-maker--small-card"
    draggable
  >
    <span>{{ name }}</span>
  </div>
</template>

<script>
export default {
  name: "SmallCard",
  props: {
    name: {
      type: String,
      default: null
    }
  }
};
</script>
