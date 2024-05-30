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
      <Breadcrumb :model="activeNode" />
      <Project :model="activeNode" />
    </section>
  </div>
</template>

<script>
import SectionZero from '../components/SectionZero.vue';
import Project from '../components/Project.vue';
import Breadcrumb from '../components/Breadcrumb.vue';
import { ActiveNodeMixin } from '../lib/mixins/active-node';

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
