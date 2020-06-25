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

    <template v-for="i in jsonDepth - 1">
      <section
        v-if="isOpen(i)"
        :key="i"
        :class="[`level_${i}`, `cat_${color}`]"
      >
        <!-- general breadcrumb -->
        <Breadcrumb
          :model="activeNode"
          :json="json"
          :options="options"
        />

        <!-- next to last children template -->
        <template v-if="i === jsonDepth - 1">
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
import { findRecursive } from "../lib/helpers";

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
      jsonDepth: 0,
      customFields: [],
      availablePlugins: {},
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
      json_depth
    } = this.options;

    this.jsonDepth = +json_depth - 1;

    const {
      params: { id }
    } = this.$route;
    this.setActiveNode(id);
  },
  methods: {
    setActiveNode(id) {
      this.activeNode = findRecursive(this.json, id);

      if (this.activeNode) {
        const {
          level,
          attributes: { custom_field_records = [], plugins_data = {} } = {}
        } = this.activeNode;

        // if the activeNode is level zero, it sets the children colors
        if (level === 0) {
          this.rootid = this.json.findIndex(d => d.id === id);
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
    isOpen(level) {
      if (this.activeNode.level === undefined) return false;

      let isOpen = false;
      if (this.activeNode.level === 0) {
        // activeNode = 0, it means is a "line"
        // then, it shows level_0 and level_1
        isOpen = level < 2;
      } else {
        // activeNode = X
        if (this.activeNode.type === "node") {
          // type = node, it means there's no further levels, then it shows as previous one
          isOpen = level === 0 || level === this.activeNode.level;
        } else {
          // then, it shows level_0 and level_(X+1), but not those between
          isOpen = level === 0 || level === this.activeNode.level + 1;
        }
      }

      return isOpen;
    }
  }
};
</script>
