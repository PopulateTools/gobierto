<template>
  <div class="investments-home-main--gallery">
    <GalleryItem
      v-for="item in items"
      :key="item.id"
      :item="item"
    />
  </div>
</template>

<script>
import GalleryItem from "./GalleryItem.vue";

export default {
  name: "Gallery",
  components: {
    GalleryItem
  },
  props: {
    items: {
      type: Array,
      default: () => []
    }
  }
};
</script>