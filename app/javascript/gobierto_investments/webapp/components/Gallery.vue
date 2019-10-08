<template>
  <div
    v-if="items.length"
    class="investments-home-main--gallery"
  >
    <GalleryItem
      v-for="item in items"
      :key="item.id"
      :item="item"
    />
  </div>
  <div v-else>
    {{ labelEmpty }}
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
  },
  data() {
    return {
      labelEmpty: ""
    }
  },
  created() {
    this.labelEmpty = I18n.t("gobierto_investments.projects.empty");
  },
};
</script>