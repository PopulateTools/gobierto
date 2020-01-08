<template>
  <div>
    <p>Tabla</p>
  </div>
</template>

<script>

export default {
  name: "Table",
  props: {
    items: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
    }
  }
};
</script>
