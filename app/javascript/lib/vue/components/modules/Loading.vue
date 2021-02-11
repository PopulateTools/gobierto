<template>
  <div>
    <i class="fas fa-spinner fa-spin" /> {{ message }}
  </div>
</template>

<script>
export default {
  name: "Loading",
  props: {
    message: {
      type: String,
      default: ""
    }
  }
};
</script>
