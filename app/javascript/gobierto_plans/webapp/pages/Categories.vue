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
        <Breadcrumb
          :model="activeNode"
          :options="options"
        />

        <!-- next to last children template -->
        <template v-if="i === lastLevel - 1">
          <div class="node-action-line">
            <ActionLineHeader :model="activeNode" />
            <ActionLines
              :models="activeNode.children"
              :options="options"
            />
          </div>
        </template>
        <!-- otherwise, recursive templates -->
        <template v-else>
          <RecursiveHeader :model="activeNode" />
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
import SectionZero from "../components/SectionZero";
import Breadcrumb from "../components/Breadcrumb";
import ActionLineHeader from "../components/ActionLineHeader";
import ActionLines from "../components/ActionLines";
import RecursiveHeader from "../components/RecursiveHeader";
import RecursiveLines from "../components/RecursiveLines";
import { translate } from "lib/shared";
import { ActiveNodeMixin } from "../lib/mixins";
import { PlansStore } from "../lib/store";

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
    this.rootOptions = PlansStore.state.levelKeys["level0_options"] || {}
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
