<template>
  <header class="layout-header">
    <div
      class="layout-header-editable"
      :class="{'is-highlight': highlight }"
    >
      <slot />
    </div>
    <div class="layout-header-shadow" />
  </header>
</template>

<script>
export default {
  name: "Header",
  props: {
    highlight: {
      type: Boolean,
      default: false,
    }
  }
}
</script>