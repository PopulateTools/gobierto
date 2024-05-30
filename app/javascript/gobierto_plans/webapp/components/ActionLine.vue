<template>
  <li>
    <NodeList
      :model="model"
      :max-category-level="maxCategoryLevel"
      @toggle="showContent = !showContent"
    >
      <NumberLabel
        :length="children.length"
        :level="level + 1"
      />
    </NodeList>

    <transition name="slide">
      <template v-if="showContent">
        <slot />
      </template>
    </transition>
  </li>
</template>

<script>
import NodeList from './NodeList.vue'
import NumberLabel from './NumberLabel.vue';

export default {
  name: "ActionLine",
  components: {
    NodeList,
    NumberLabel
  },
  props: {
    model: {
      type: Object,
      default: () => {}
    },
    options: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      showContent: false,
      level: 0,
      maxCategoryLevel: 0,
      children: []
    };
  },
  created() {
    const { level, children } = this.model;
    const { max_category_level } = this.options;
    this.level = level;
    this.children = children;
    this.maxCategoryLevel = max_category_level;
  },
};
</script>
