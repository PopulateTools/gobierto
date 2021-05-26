<template>
  <div class="investments-project-main">
    <section>
      <h1 class="investments-project-main--heading">
        {{ project.title }}
      </h1>
    </section>

    <section v-if="hasGallery">
      <div class="investments-project-main--carousel">
        <HorizontalCarousel :thumbnails="true">
          <div
            v-for="photo in gallery"
            :key="photo"
            class="investments-project-main--carousel-element"
          >
            <img
              :src="photo"
              :alt="project.description"
              class="investments-project-main--carousel-img"
            >
            <img
              :src="photo"
              :alt="project.description"
              class="investments-project-main--carousel-blur"
            >
          </div>
        </HorizontalCarousel>
      </div>
    </section>

    <section v-if="hasAttributes">
      <h4 class="investments-project-main--subheading">
        {{ labelTechs }}
      </h4>

      <template v-for="({ id, type, field_type, name, icon, table, value }, i) in attributes">
        <!-- Separator -->
        <div
          v-if="type === 'separator'"
          :key="`${id}-${i}`"
          class="p_v_1"
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
  </div>
</template>

<script>
import { HorizontalCarousel, ReadMore } from "lib/vue/components";
import { CommonsMixin } from "../../mixins/common.js";
import DictionaryItem from "../../components/DictionaryItem.vue";

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
      visibleItems: 1,
      labelDesc: I18n.t("gobierto_investments.projects.description") || "",
      labelTechs: I18n.t("gobierto_investments.projects.tech_sheet") || "",
    };
  },
  computed: {
    hasGallery() {
      return !!this.gallery.length
    },
    hasAttributes() {
      return !!this.attributes.length
    }
  },
  created() {
    this.setDisplay();
  },
  updated() {
    this.setDisplay();
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
    }
  }
};
</script>
