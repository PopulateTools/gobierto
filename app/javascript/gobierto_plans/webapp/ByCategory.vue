<template>
  <div class="planification-content">
    <section
      class="level_0"
      :class="{ 'is-active': isOpen(0), 'is-mobile-open': openMenu }"
    >
      <template v-for="(model, index) in json">
        <NodeRoot
          :key="model.id"
          :element-index="index"
          :elements-length="json.length"
          :classes="[
            `cat_${(index % json.length) + 1}`,
            { 'is-root-open': parseInt(activeNode.uid) === index }
          ]"
          :model="model"
          @selection="setSelection"
          @open-menu-mobile="openMenu = !openMenu"
        />
      </template>
    </section>

    <!-- TODO: pruebas -->
    <template v-for="i in jsonDepth">
      <section
        v-if="isOpen(i)"
        :key="i"
        :class="[`level_${i}`, `cat_${color()}`]"
      >
        <div class="node-breadcrumb mb2">
          <a @click.stop="resetParent">
            {{ labelStarts }}
          </a>

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

        <!-- last children -->
        <template v-if="i === jsonDepth">
          <div class="node-action-line">
            <ActionLineHeader :node="activeNode">
              <NumberLabel
                :keys="levelKeys"
                :length="activeNode.children.length"
                :level="activeNode.level"
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
                        :level="model.level"
                      />
                    </template>

                    <TableView
                      :key="model.id"
                      :model="model"
                      :header="showTableHeader"
                      :open="openNode"
                      @activate="activatePlugins"
                      @custom-fields="parseCustomFields"
                      @selection="setSelection"
                    >
                      <NumberLabel
                        :keys="levelKeys"
                        :level="model.level"
                      />
                    </TableView>
                  </ActionLine>
                </template>
              </ul>
            </div>
          </div>
        </template>
        <template v-else>
          <div class="lines-header">
            <NumberLabel
              :keys="levelKeys"
              :length="activeNode.children.length"
              :level="activeNode.level"
            />

            <div>{{ labelProgress }}</div>
          </div>

          <ul class="lines-list">
            <li
              v-for="model in activeNode.children"
              :key="model.id"
              class="mb2"
            >
              <NodeList
                :model="model"
                :level="levelKeys"
                @selection="setSelection"
              >
                <NumberLabel
                  :keys="levelKeys"
                  :length="model.children.length"
                  :level="model.level"
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
import NodeRoot from "./components/NodeRoot";
import NodeList from "./components/NodeList";
import TableView from "./components/TableView";
import ActionLineHeader from "./components/ActionLineHeader";
import ActionLine from "./components/ActionLine";
import NumberLabel from "./components/NumberLabel";
import { translate, percent } from "lib/shared";
import { depth } from "../lib/helpers";

export default {
  name: "ByCategory",
  filters: {
    translate,
    percent
  },
  components: {
    NodeRoot,
    ActionLineHeader,
    ActionLine,
    NumberLabel,
    NodeList,
    TableView
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
      labelStarts: I18n.t("gobierto_plans.plan_types.show.starts") || "",
      labelSeeAll: I18n.t("gobierto_plans.plan_types.show.see_all") || "",
      labelProgress:
        I18n.t("gobierto_plans.plan_types.show.percentage_progress") || "",
      activeNode: {},
      levelKeys: {},
      openNode: false,
      showTableHeader: false,
      jsonDepth: 0,
      showTable: {}
    };
  },
  created() {
    const { level_keys, open_node, show_table_header } = this.options;

    this.levelKeys = level_keys;
    this.openNode = open_node;
    this.showTableHeader = show_table_header;

    // Maximum depth of all objects in the json
    this.jsonDepth = Math.max(...this.json.map(depth)) - 1;
  },
  methods: {
    setSelection(model) {
      this.activeNode = model;
      // To know the root node
      this.rootid = this.activeNode.uid.toString().charAt(0);
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
    color() {
      return (this.rootid % this.json.length) + 1;
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
    }
  }
};
</script>
