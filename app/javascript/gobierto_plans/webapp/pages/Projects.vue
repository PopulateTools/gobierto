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

    <section :class="[`level_${lastLevel}`, `cat_${color}`]">
      <Breadcrumb
        :model="activeNode"
        :json="json"
        :options="options"
      />

      <Project
        :model="activeNode"
        :custom-fields="customFields"
        :plugins="availablePlugins"
      />
    </section>
  </div>
</template>

<script>
import NodeRoot from "../components/NodeRoot";
import Project from "../components/Project";
import Breadcrumb from "../components/Breadcrumb";
import { ActiveNodeMixin } from "../lib/mixins";

export default {
  name: "Projects",
  components: {
    NodeRoot,
    Project,
    Breadcrumb,
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
  }
};
</script>
