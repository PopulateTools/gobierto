<template>
  <section
    class="level_0"
    :class="{ 'is-active': active, 'is-mobile-open': openMenu }"
  >
    <template v-for="(model, index) in json">
      <NodeRoot
        :key="model.id"
        :classes="[
          'category',
          { 'is-root-open': rootid === index }
        ]"
        :model="model"
        :options="{ ...rootOptions[index] || {}, hideCounter }"
        :style="`--category: var(--category-${(index % json.length) + 1})`"
        @open-menu-mobile="openMenu = !openMenu"
      />
    </template>
  </section>
</template>

<script>
import NodeRoot from "../components/NodeRoot";
import { PlansStore } from "../lib/store";

export default {
  name: "SectionZero",
  components: {
    NodeRoot
  },
  props: {
    active: {
      type: Boolean,
      default: false
    },
    json: {
      type: Array,
      default: () => []
    },
    rootid: {
      type: Number,
      default: null
    }
  },
  data() {
    return {
      openMenu: false,
      hideCounter: false,
      rootOptions: {}
    };
  },
  created() {
    const { options } = PlansStore.state
    this.rootOptions = options["level0_options"] || {};
    this.hideCounter = options["hide_level0_counters"]
  }
};
</script>
