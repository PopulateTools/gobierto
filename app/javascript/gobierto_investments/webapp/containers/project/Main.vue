<template>
  <main>
    <h1 class="investments-project-main--heading">
      {{ project.title | translate }}
    </h1>

    <div
      v-if="project.description"
      class="investments-project-main--intro"
    >
      <ReadMore :round-chars="300">
        {{ project.description }}
      </ReadMore>
    </div>

    <div class="investments-project-main--carousel">
      <HorizontalCarousel :visible-items="visibleItems">
        <img
          v-for="photo in gallery"
          :key="photo"
          :src="photo"
          class="js-image-lightbox"
        >
      </HorizontalCarousel>
    </div>

    <div>
      <template v-for="attr in attributes">
        <DictionaryItem
          v-if="attr.filter === 'translate'"
          :key="attr.id"
          :name="attr.name | translate"
          :value="attr.value | translate"
          :type="attr.type"
          :icon="attr.icon"
        />
        <DictionaryItem
          v-else-if="attr.filter === 'money'"
          :key="attr.id"
          :name="attr.name | translate"
          :value="attr.value | money"
          :type="attr.type"
          :icon="attr.icon"
        />
        <!-- <DictionaryItem
          v-else-if="attr.filter === 'tableList'"
          :key="attr.id"
          :name="attr.name | translate"
          :value="attr.value | tableList(attr.options)"
        /> -->
        <DictionaryItem
          v-else
          :key="attr.id"
          :name="attr.name | translate"
          :value="attr.value"
          :type="attr.type"
          :icon="attr.icon"
        />
      </template>
    </div>
  </main>
</template>

<script>
import DictionaryItem from "../../components/DictionaryItem.vue";
import HorizontalCarousel from "../../components/HorizontalCarousel.vue";
import ReadMore from "../../components/ReadMore.vue";
import { ImageLightbox } from "lib/shared";
import { CommonsMixin } from "../../mixins/common.js";
import Vue from "vue"

export default {
  name: "ProjectMain",
  components: {
    DictionaryItem,
    HorizontalCarousel,
    ReadMore
  },
  mixins: [CommonsMixin],
  props: {
    project: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      attributes: {},
      gallery: [],
      visibleItems: 3
    };
  },
  created() {
    const { gallery = [], availableProjectFields = [] } = this.project
    this.gallery = gallery
    this.attributes = availableProjectFields

    if (gallery.length < this.visibleItems) {
      this.visibleItems = gallery.length
    }
  },
  mounted() {
    const lightboxes = this.$el.querySelectorAll(".js-image-lightbox");
    lightboxes.forEach(lightbox => new ImageLightbox(lightbox));
  },
  methods: {
      dynamicFilter: function (value, filter) {
    return Vue.filter(filter)(value)
  }
  }
};
</script>

