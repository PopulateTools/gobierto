<template>
  <i
    :class="rotate ? '' : 'rotate-caret'"
    class="fas fa-caret-down"
  />
</template>

<script>
export default {
  name: 'Caret',
  props: {
    rotate: {
      type: Boolean,
      default: true
    },
  }
}
</script>
