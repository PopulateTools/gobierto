<template>
  <li>
    <NodeList
      :model="model"
      @toggle="showContent = !showContent"
    >
      <NumberLabel
        :length="childrenCount"
        :level="level + 1"
      />
    </NodeList>

    <transition name="slide-fade">
      <template v-if="showContent">
        <slot />
      </template>
    </transition>
  </li>
</template>

<script>
import NodeList from './NodeList'
import NumberLabel from "./NumberLabel";

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
    }
  },
  data() {
    return {
      showContent: false,
      childrenCount: 0,
      level: 0
    };
  },
    created() {
    const { attributes: { children_count } = {}, level } = this.model;

    this.childrenCount = children_count;
    this.level = level;
  },
};
</script>
