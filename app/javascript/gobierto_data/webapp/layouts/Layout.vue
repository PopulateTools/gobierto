<template>
  <div class="gobierto-data">
    <div class="pure-g gutters m_b_1">
      <div class="pure-u-1 pure-u-lg-1-4 gobierto-data-layout-column gobierto-data-layout-sidebar">
        <slot name="sidebar" />
      </div>

      <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
        <slot />
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "Layout"
}
</script>
