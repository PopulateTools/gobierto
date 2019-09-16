<template>
  <div class="horizontal-carousel js-horizontal-carousel" :data-visible-items="visibleItems">
    <div class="horizontal-carousel-content">
      <slot></slot>
    </div>

    <div data-prev>
      <i class="fas fa-angle-left fa-2x"></i>
    </div>
    <div data-next>
      <i class="fas fa-angle-right fa-2x"></i>
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