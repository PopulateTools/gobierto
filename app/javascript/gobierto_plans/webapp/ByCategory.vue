<template>
  <section
    class="level_0"
    :class="{ 'is-active': false, 'is-mobile-open': openMenu }"
  >
    <!-- <section
      class="level_0"
      :class="{ 'is-active': isOpen(0), 'is-mobile-open': openMenu }"
    > -->
    <!-- <div
        v-for="(model, index) in json"
        class="node-root"
        :class="['cat_' + setRootColor(index), { 'is-root-open': parseInt(activeNode.uid) === index } ]"
      > -->
    <template v-for="(model, index) in json">
      <NodeRoot
        :key="model.id"
        :element-index="index"
        :elements-length="json.length"
        :model="model"
        @open-menu-mobile="openMenu = !openMenu"
      />
    </template>
  </section>
</template>

<script>
import NodeRoot from "./components/NodeRoot";

export default {
  name: "ByCategory",
  components: {
    NodeRoot
  },
  props: {
    json: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      openMenu: false
    }
  }
};
</script>
