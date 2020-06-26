<template>
  <div class="planification-content">
    <section
      class="level_0 is-active"
      :class="{ 'is-mobile-open': openMenu }"
    >
      <template v-for="(model, index) in json">
        <NodeRoot
          :key="model.id"
          :classes="[
            `cat_${(index % json.length) + 1}`,
            { 'is-root-open': parseInt(activeNode.uid) === index }
          ]"
          :model="model"
          @open-menu-mobile="openMenu = !openMenu"
        />
      </template>
    </section>

    <!-- avoid last level, as they're projects -->
    <template v-for="i in lastLevel - 1">
      <section
        v-if="isOpen(i)"
        :key="i"
        :class="[`level_${i}`, `cat_${color}`]"
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
import NodeRoot from "../components/NodeRoot";
import Breadcrumb from "../components/Breadcrumb";
import ActionLineHeader from "../components/ActionLineHeader";
import ActionLines from "../components/ActionLines";
import RecursiveHeader from "../components/RecursiveHeader";
import RecursiveLines from "../components/RecursiveLines";
import { translate } from "lib/shared";
import { ActiveNodeMixin } from "../lib/mixins";

export default {
  name: "Categories",
  filters: {
    translate
  },
  components: {
    NodeRoot,
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
      openMenu: false,
      lastLevel: 0
    };
  },
  created() {
    const { last_level } = this.options;
    this.lastLevel = last_level;
  },
  methods: {
    isOpen(level) {
      const { level: currentLevel } = this.activeNode
      const { max_category_level } = this.options

// TODO: incomplete
      return (level - 1) === currentLevel || max_category_level === currentLevel
    }
  }
};
</script>
