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

    <section
      :class="[`level_${jsonDepth}`, `cat_${color}`]"
    >
      <!-- TODO: falta breadcrumb -->
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
import { findRecursive } from "../../lib/helpers";

export default {
  name: "Projects",
  components: {
    NodeRoot,
    Project
  },
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
      activeNode: {},
      levelKeys: {},
      openNode: false,
      showTableHeader: false,
      jsonDepth: 0,
      customFields: {},
      availablePlugins: [],
      rootid: 0
    };
  },
  computed: {
    color() {
      return (this.rootid % this.json.length) + 1;
    }
  },
  watch: {
    $route(to) {
      const {
        params: { id }
      } = to;
      this.setActiveNode(id);
    }
  },
  created() {
    const {
      level_keys,
      open_node,
      show_table_header,
      json_depth
    } = this.options;

    this.levelKeys = level_keys;
    this.openNode = open_node;
    this.showTableHeader = show_table_header;
    this.jsonDepth = +json_depth - 1;

    const {
      params: { id }
    } = this.$route;
    this.setActiveNode(id);
  },
  methods: {
    async setActiveNode(id) {
      this.activeNode = findRecursive(this.json, +id);

      if (this.activeNode) {
        const {
          level,
          attributes: { custom_field_records = [], plugins_data = {} }
        } = this.activeNode;

        // if the activeNode is level zero, it sets the children colors
        if (level === 0) {
          this.rootid = this.json.findIndex(d => d.id === +id);
        }

        // Preprocess custom fields
        if (custom_field_records.length > 0) {
          this.customFields = custom_field_records;
        }

        // Activate plugins
        if (Object.keys(plugins_data).length) {
          this.availablePlugins = plugins_data;
        }
      }
    },
  }
};
</script>
