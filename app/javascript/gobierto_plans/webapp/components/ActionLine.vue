<template>
  <li>
    <NodeList
      :model="model"
      @toggle="showContent = !showContent"
    >
      <slot name="numberLabel" />
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

export default {
  name: "ActionLine",
  components: {
    NodeList
  },
  props: {
    model: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      showContent: false
    };
  },
};
</script>
