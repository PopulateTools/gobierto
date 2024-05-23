<template>
  <div class="planification-content">
    <SectionZero
      :json="json"
      :active="true"
      :rootid="rootid"
    />

    <!-- avoid last level, as they're projects -->
    <template v-for="i in lastLevel - 1">
      <section
        v-if="isOpen(i)"
        :key="i"
        :class="[`level_${i}`, 'category']"
        :style="`--category: var(--category-${color})`"
      >
        <Breadcrumb :model="activeNode" />

        <!-- next to last children template -->
        <template v-if="i === lastLevel - 1">
          <div class="node-action-line">
            <ActionLineHeader
              :key="color"
              :model="activeNode"
            />
            <ActionLines
              :models="activeNode.children"
              :options="options"
            />
          </div>
        </template>
        <!-- otherwise, recursive templates -->
        <template v-else>
          <RecursiveHeader
            :key="color"
            :model="activeNode"
          />
          <RecursiveLines
            :models="activeNode.children"
            :options="options"
          />
        </template>
      </section>
    </template>
  </div>
</template>

<script>
import SectionZero from '../components/SectionZero.vue';
import Breadcrumb from '../components/Breadcrumb.vue';
import ActionLineHeader from '../components/ActionLineHeader.vue';
import ActionLines from '../components/ActionLines.vue';
import RecursiveHeader from '../components/RecursiveHeader.vue';
import RecursiveLines from '../components/RecursiveLines.vue';
import { translate } from '../../../lib/vue/filters';
import { ActiveNodeMixin } from '../lib/mixins/active-node';
import { PlansStore } from '../lib/store';

export default {
  name: "Categories",
  filters: {
    translate
  },
  components: {
    SectionZero,
    Breadcrumb,
    ActionLineHeader,
    ActionLines,
    RecursiveHeader,
    RecursiveLines
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
      lastLevel: 0,
    };
  },
  created() {
    const { last_level } = this.options;
    this.lastLevel = last_level;
    this.rootOptions = PlansStore.state.options["level0_options"] || {}
  },
  methods: {
    isOpen(level) {
      const { level: currentLevel } = this.activeNode
      const { max_category_level } = this.options

      return (level - 1) === currentLevel || (max_category_level === currentLevel && level === currentLevel)
    }
  }
};
</script>
