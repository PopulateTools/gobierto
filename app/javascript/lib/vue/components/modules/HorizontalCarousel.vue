<template>
  <div
    :data-visible-items="items"
    :data-thumbnails="thumbnails"
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
import { HorizontalCarousel } from '../../../../lib/shared';

export default {
  name: "HorizontalCarousel",
  props: {
    visibleItems: {
      type: Number,
      default: 3
    },
    thumbnails: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      items: this.visibleItems
    }
  },
  mounted() {
    const images = this.$el.firstElementChild?.children;
    if (images.length < this.items) {
      this.items = images.length;
    }

    this.$nextTick(() => {
      // if this.items changes, we need to wait for the next DOM update before initializing the carousel
      this.horizontalCarousel = new HorizontalCarousel(this.$el);
    })
  },
  beforeDestroy() {
    this.horizontalCarousel.destroy();
  }
};
</script>
