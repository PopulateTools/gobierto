<template>
  <div v-if="items.length">
    <!-- <div
      class="investments-home-main--gallery"
    >
    </div> -->
    <transition-group
      name="fade"
      mode="out-in"
      tag="div"
      class="investments-home-main--gallery"
    >
      <GalleryItem
        v-for="item in visibleItems"
        :key="item.id"
        :item="item"
      />
    </transition-group>

    <ShowAll @show-all="showAll" />
  </div>
  <div v-else>
    {{ labelEmpty }}
  </div>
</template>

<script>
import GalleryItem from "./GalleryItem.vue";
import ShowAll from "./ShowAll.vue";

export default {
  name: "Gallery",
  components: {
    GalleryItem,
    ShowAll
  },
  props: {
    items: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelEmpty: "",
      visibleItems: [],
      maxItems: 24
    };
  },
  created() {
    this.labelEmpty = I18n.t("gobierto_investments.projects.empty");
    this.visibleItems = this.items.slice(0, this.maxItems);
  },
  methods: {
    showAll(isAllVisible) {
      this.visibleItems = isAllVisible ? this.items : this.items.slice(0, this.maxItems)
    }
  }
};
</script>
