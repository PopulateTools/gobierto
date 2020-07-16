<template>
  <div class="planification-content">
    <SectionZero
      :json="json"
      :active="true"
      :rootid="rootid"
    />

    <section
      :class="[`level_${lastLevel}`, 'category']"
      :style="`--category: var(--category-${color})`"
    >
      <Breadcrumb
        :model="activeNode"
        :options="options"
      />

      <Project
        :model="activeNode"
        :options="options"
      />
    </section>
  </div>
</template>

<script>
import SectionZero from "../components/SectionZero";
import Project from "../components/Project";
import Breadcrumb from "../components/Breadcrumb";
import { ActiveNodeMixin } from "../lib/mixins";

export default {
  name: "Projects",
  components: {
    SectionZero,
    Project,
    Breadcrumb
  },
  mixins: [ActiveNodeMixin],
  props: {
    json: {
      type: Array,
      default: () => []
    },
    options: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      lastLevel: 0
    };
  },
  created() {
    const { last_level } = this.options;
    this.lastLevel = last_level;
  }
};
</script>
