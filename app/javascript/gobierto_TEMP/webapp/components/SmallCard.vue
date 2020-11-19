<template>
  <div class="dashboards-maker--small-card">
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
