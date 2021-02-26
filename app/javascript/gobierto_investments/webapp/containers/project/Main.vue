<template>
  <main class="investments-project-main">
    <section>
      <h1 class="investments-project-main--heading">
        {{ project.title }}
      </h1>
    </section>

    <section v-if="project.gallery">
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
    </section>

    <section v-if="attributes.length">
      <h4 class="investments-project-main--subheading">
        {{ labelTechs }}
      </h4>

      <template v-for="({ id, type, field_type, name, icon, table, value }, i) in attributes">
        <!-- Separator -->
        <div
          v-if="type === 'separator'"
          :key="`${id}-${i}`"
          class="p_v_2"
        />

        <template v-else>
          <DictionaryItem
            v-if="field_type === 'money'"
            :key="`${id}-${i}`"
            :name="name"
            :value="value | money"
            :type="type"
            :icon="icon"
            :table="table"
          />
          <DictionaryItem
            v-else-if="field_type === 'date'"
            :key="`${id}-${i}`"
            :name="name"
            :value="value | date"
            :type="type"
            :icon="icon"
            :table="table"
          />
          <DictionaryItem
            v-else
            :key="`${id}-${i}`"
            :name="name"
            :value="value"
            :type="type"
            :icon="icon"
            :table="table"
          />
        </template>
      </template>
    </section>

    <section v-if="project.description">
      <div class="investments-project-main--intro">
        <h4 class="investments-project-main--subheading">
          {{ labelDesc }}
        </h4>

        <ReadMore :round-chars="300">
          {{ project.description }}
        </ReadMore>
      </div>
    </section>
  </main>
</template>

<script>
import DictionaryItem from "../../components/DictionaryItem.vue";

import { HorizontalCarousel, ReadMore } from "lib/vue/components";
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
      visibleItems: 3,
      labelDesc: I18n.t("gobierto_investments.projects.description") || "",
      labelTechs: I18n.t("gobierto_investments.projects.tech_sheet") || "",
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
          (!(value instanceof Array && value.length === 0))
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
