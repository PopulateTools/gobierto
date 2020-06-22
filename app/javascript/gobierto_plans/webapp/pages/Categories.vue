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

    <template v-for="i in jsonDepth">
      <section
        v-if="isOpen(i)"
        :key="i"
        :class="[`level_${i}`, `cat_${color}`]"
      >
        <!-- general breadcrumb -->
        <div class="node-breadcrumb mb2">
          <a @click="activeNode = {}">
            {{ labelStarts }}
          </a>

          <!-- TODO: refactor setParent/getParent -->
          <template v-for="level in activeNode.level">
            <a
              :key="level"
              @click.stop="setParent(level)"
            >
              <i class="fas fa-caret-right" />
              {{ (getParent(level).attributes || {}).title | translate }}
            </a>
          </template>
        </div>

        <!-- last children template -->
        <!-- TODO: SACAR de ahi -->
        <template v-if="i === jsonDepth">
          <Project
            :model="activeNode"
            :custom-fields="customFields"
            :plugins="availablePlugins"
          />
        </template>
        <!-- next to last children template -->
        <template v-else-if="i === jsonDepth - 1">
          <div class="node-action-line">
            <ActionLineHeader :node="activeNode">
              <NumberLabel
                :keys="levelKeys"
                :length="activeNode.children.length"
                :level="activeNode.level + 1"
              />
            </ActionLineHeader>

            <div class="node-action-line">
              <ul class="action-line--list">
                <template v-for="model in activeNode.children">
                  <ActionLine
                    :key="model.id"
                    :model="model"
                  >
                    <template v-slot:numberLabel>
                      <NumberLabel
                        :keys="levelKeys"
                        :length="model.attributes.children_count"
                        :level="model.level + 1"
                      />
                    </template>

                    <TableView
                      :key="model.id"
                      :model="model"
                      :header="showTableHeader"
                      :open="openNode"
                    >
                      <NumberLabel
                        :keys="levelKeys"
                        :level="model.level + 1"
                      />
                    </TableView>
                  </ActionLine>
                </template>
              </ul>
            </div>
          </div>
        </template>
        <!-- otherwise, recursive templates -->
        <template v-else>
          <div class="lines-header">
            <NumberLabel
              :keys="levelKeys"
              :length="activeNode.children.length"
              :level="activeNode.level + 1"
            />

            <div>% {{ labelProgress }}</div>
          </div>

          <ul class="lines-list">
            <li
              v-for="model in activeNode.children"
              :key="model.id"
              class="mb2"
            >
              <NodeList :model="model">
                <NumberLabel
                  :keys="levelKeys"
                  :length="model.children.length"
                  :level="model.level + 1"
                />
              </NodeList>
            </li>
          </ul>
        </template>
      </section>
    </template>
  </div>
</template>

<script>
import NodeRoot from "../components/NodeRoot";
import NodeList from "../components/NodeList";
import TableView from "../components/TableView";
import ActionLineHeader from "../components/ActionLineHeader";
import ActionLine from "../components/ActionLine";
import NumberLabel from "../components/NumberLabel";
import Project from "../components/Project";
import { translate, percent, date } from "lib/shared";
import { findRecursive } from "../../lib/helpers";

export default {
  name: "Categories",
  filters: {
    translate,
    percent,
    date
  },
  components: {
    NodeRoot,
    ActionLineHeader,
    ActionLine,
    NumberLabel,
    NodeList,
    TableView,
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
      labelStarts: I18n.t("gobierto_plans.plan_types.show.starts") || "",
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
    setActiveNode(id) {
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
    },
    getParent() {
      // Initialize args
      var breakpoint =
        arguments.length > 0 && arguments[0] !== undefined
          ? arguments[0]
          : undefined;

      // From uid, turno into array all parents, and drop last item (myself)
      var ancestors = _.dropRight(this.activeNode.uid.split(".")).map(Number);

      var current = this.json; // First item. ROOT item
      for (var i = 0; i < ancestors.length; i++) {
        if (i === breakpoint) {
          // If there is breakpoint, I get the corresponding ancestor set by breakpoint
          break;
        }

        if (!_.isArray(current)) {
          current = current.children;
        }
        current = current[ancestors[i]];
      }

      return current || {};
    },
    setParent() {
      // Initialize args
      var breakpoint =
        arguments.length > 0 && arguments[0] !== undefined
          ? arguments[0]
          : undefined;
      // //hack 3rd level (3rd level has no SECTION)
      // if (breakpoint === 3) breakpoint = breakpoint - 1;

      this.activeNode = this.getParent(breakpoint);
    }
  }
};
</script>
