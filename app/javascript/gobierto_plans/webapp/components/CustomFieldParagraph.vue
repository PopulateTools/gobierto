<template>
  <div>
    <div
      class="project-description__content"
      :class="[isActive ? 'is-hidden' : '']"
      v-html="value"
    />

    <button
      v-if="isElementHidden"
      class="project-description__more"
      @click="isActive = !isActive"
    >
      <span v-if="readMoreButton">{{ labelReadMore }}</span>
      <span v-else>{{ labelReadLess }}</span>
    </button>
  </div>
</template>

<script>
import { translate } from '../../../lib/vue/filters';

export default {
  name: "CustomFieldParagraph",
  filters: {
    translate
  },
  props: {
    attributes: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      value: null,
      title: null,
      readMoreButton: true,
      isActive: false,
      labelDesc: I18n.t("gobierto_plans.plan_types.show.desc") || "",
      labelReadMore: I18n.t("gobierto_plans.plan_types.show.read_more") || "",
      labelReadLess: I18n.t("gobierto_plans.plan_types.show.read_less") || ""
    };
  },
  computed: {
    isElementHidden() {
      return this.value && this.value.length > 200;
    }
  },
  created() {
    const { value, name_translations } = this.attributes;
    this.value = value;
    this.title = name_translations;
    this.isActive = this.isElementHidden
  }
};
</script>
