<template>
  <i
    :class="rotate ? '' : 'rotate-caret'"
    class="fas fa-caret-down"
    style="color: var(--color-base);"
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
