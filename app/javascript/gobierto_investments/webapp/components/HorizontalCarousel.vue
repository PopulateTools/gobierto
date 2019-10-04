<template>
  <div
    :data-visible-items="visibleItems"
    class="horizontal-carousel js-horizontal-carousel"
  >
    <div class="horizontal-carousel-content">
      <slot />
    </div>

    <div data-prev>
      <i class="fas fa-angle-left fa-2x" />
    </div>
    <div data-next>
      <i class="fas fa-angle-right fa-2x" />
    </div>
  </div>
</template>

<script>
import { HorizontalCarousel } from "lib/shared";

export default {
  name: "HorizontalCarousel",
  props: {
    visibleItems: {
      type: Number,
      default: 3
    }
  },
  mounted() {
    new HorizontalCarousel(this.$el);
  }
};
</script>