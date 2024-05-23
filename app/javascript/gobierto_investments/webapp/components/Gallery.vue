<template>
  <div v-if="items.length">
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

    <ShowAll
      v-if="items.length > maxItems"
      @show-all="showAll"
    />
  </div>
  <div v-else>
    {{ labelEmpty }}
  </div>
</template>

<script>
import GalleryItem from './GalleryItem.vue';
import ShowAll from './ShowAll.vue';

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
      isAllVisible: false,
      maxItems: 24
    };
  },
  computed: {
    visibleItems() {
      return this.isAllVisible ? this.items : this.items.slice(0, this.maxItems);
    }
  },
  created() {
    this.labelEmpty = I18n.t("gobierto_investments.projects.empty");
  },
  methods: {
    showAll(isAllVisible) {
      this.isAllVisible = isAllVisible
    }
  }
};
</script>
