<template>
  <header class="layout-header">
    <div class="layout-header-editable">
      <slot />
    </div>
    <div class="layout-header-shadow" />
  </header>
</template>

<script>
export default {
  name: "Header",
}
</script>