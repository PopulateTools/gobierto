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
          v-if="attr.filter === 'money'"
          :key="attr.id"
          :name="attr.name"
          :value="attr.value | money"
          :type="attr.type"
          :icon="attr.icon"
          :table="attr.table"
        />
        <DictionaryItem
          v-else-if="attr.filter === 'date'"
          :key="attr.id"
          :name="attr.name"
          :value="attr.value | date"
          :type="attr.type"
          :icon="attr.icon"
          :table="attr.table"
        />
        <DictionaryItem
          v-else
          :key="attr.id"
          :name="attr.name"
          :value="attr.value"
          :type="attr.type"
          :icon="attr.icon"
          :table="attr.table"
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
import { GobiertoInvestmentsSharedMixin } from "../../mixins/common.js";

export default {
  name: "ProjectMain",
  components: {
    DictionaryItem,
    HorizontalCarousel,
    ReadMore
  },
  mixins: [GobiertoInvestmentsSharedMixin],
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
  }
};
</script>

