<template>
  <main>
    <h1 class="investments-project-main--heading">
      {{ project.title }}
    </h1>

    <div class="investments-project-main--intro">
      <ReadMore :round-chars="300">
        {{ project.description }}
      </ReadMore>
    </div>

    <div class="investments-project-main--carousel">
      <HorizontalCarousel :visible-items="visibleItems">
        <img
          class="js-image-lightbox"
          src="https://loremflickr.com/540/480/building"
          alt
        >
        <img
          class="js-image-lightbox"
          src="https://loremflickr.com/540/480/building"
          alt
        >
        <img
          class="js-image-lightbox"
          src="https://loremflickr.com/540/480/building"
          alt
        >
        <img
          class="js-image-lightbox"
          src="https://loremflickr.com/540/480/building"
          alt
        >
        <img
          class="js-image-lightbox"
          src="https://loremflickr.com/540/480/building"
          alt
        >
        <img
          class="js-image-lightbox"
          src="https://loremflickr.com/540/480/building"
          alt
        >
      </HorizontalCarousel>
    </div>

    <div>
      <template v-for="(value, name, index) in project.attributes">
        <DictionaryItem
          :key="index"
          :name="name"
          :value="value"
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

export default {
  name: "ProjectMain",
  components: {
    DictionaryItem,
    HorizontalCarousel,
    ReadMore
  },
  props: {
    project: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      attributes: {},
      visibleItems: 3
    };
  },
  mounted() {
    const lightboxes = this.$el.querySelectorAll(".js-image-lightbox");
    lightboxes.forEach(lightbox => new ImageLightbox(lightbox));
  }
};
</script>

