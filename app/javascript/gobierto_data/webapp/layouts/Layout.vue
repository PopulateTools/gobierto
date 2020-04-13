<template>
  <div class="gobierto-data">
    <div class="pure-g gutters m_b_1">
      <div class="pure-u-1 pure-u-lg-4-4">
        <slot name="navigation">
          <!-- default component -->
          <Nav />
        </slot>
      </div>

      <div class="pure-u-1 pure-u-lg-1-4 gobierto-data-layout-column gobierto-data-layout-sidebar">
        <slot name="sidebar" />
      </div>

      <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
        <slot name="main" />
      </div>
    </div>
  </div>
</template>

<script>
import Nav from "../components/Nav.vue";
export default {
  name: "Layout",
  components: {
    Nav
  }
}
</script>
