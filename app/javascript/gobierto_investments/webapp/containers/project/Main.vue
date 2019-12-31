<template>
  <main>
    <h1 class="investments-project-main--heading">
      {{ project.title }}
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
        <div
          v-for="photo in gallery"
          :key="photo"
          class="investments-project-main--carousel-element"
        >
          <img
            :src="photo"
            class="investments-project-main--carousel-img js-image-lightbox"
            @load="onload"
          >
          <img
            v-if="gallery.length <= 1"
            :src="photo"
            class="investments-project-main--carousel-blur"
          >
        </div>
      </HorizontalCarousel>
    </div>

    <div>
      <template v-for="(attr, i) in attributes">
        <!-- Separator -->
        <hr
          v-if="attr.type === 'separator'"
          :key="`${attr.type}-${i}`"
          class="investments-project-main--hr"
        >

        <template v-else>
          <DictionaryItem
            v-if="attr.filter === 'money'"
            :key="`${attr.id}-${i}`"
            :name="attr.name"
            :value="attr.value | money"
            :type="attr.type"
            :icon="attr.icon"
            :table="attr.table"
          />
          <DictionaryItem
            v-else-if="attr.filter === 'date'"
            :key="`${attr.id}-${i}`"
            :name="attr.name"
            :value="attr.value | date"
            :type="attr.type"
            :icon="attr.icon"
            :table="attr.table"
          />
          <DictionaryItem
            v-else
            :key="`${attr.id}-${i}`"
            :name="attr.name"
            :value="attr.value"
            :type="attr.type"
            :icon="attr.icon"
            :table="attr.table"
          />
        </template>
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
    this.setDisplay();
  },
  updated() {
    this.setDisplay();
  },
  mounted() {
    const lightboxes = this.$el.querySelectorAll(".js-image-lightbox");
    lightboxes.forEach(lightbox => new ImageLightbox(lightbox));
  },
  methods: {
    setDisplay() {
      const { gallery = [], availableProjectFields = [] } = this.project;
      this.gallery = gallery;

      this.attributes = availableProjectFields.filter(
        ({ type, value }) =>
          type === "separator" ||
          (value !== null &&
            value !== undefined &&
            !(value instanceof Array && value.length === 0))
      );

      if (gallery.length < this.visibleItems) {
        this.visibleItems = gallery.length;
      }
    },
    onload({ target }) {
      const { naturalHeight, naturalWidth } = target;

      if (this.gallery.length <= 1 && naturalHeight > naturalWidth) {
        target.classList.add("is-portrait");
      }
    }
  }
};
</script>
