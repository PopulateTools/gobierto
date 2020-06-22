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
        <template v-if="i === jsonDepth">
          <div class="node-action-line">
            <div class="action-line--header node-list cat--negative">
              <h3>{{ (activeNode.attributes || {}).title | translate }}</h3>
            </div>

            <div class="node-project-detail">
              <!-- Native fields -->
              <div class="project-mandatory">
                <div>
                  <div class="mandatory-list">
                    <div class="mandatory-title">
                      {{ labelProgress }}
                    </div>
                    <div class="mandatory-desc">
                      {{ activeNode.attributes.progress | percent }}
                    </div>
                  </div>
                  <div class="mandatory-progress">
                    <!-- TODO: apply math.round -->
                    <div
                      :style="{ width: activeNode.attributes.progress + '%' }"
                    />
                  </div>
                </div>
                <div>
                  <div class="mandatory-list">
                    <div class="mandatory-title">
                      {{ labelStarts }} - {{ labelEnds }}
                    </div>
                    <div class="mandatory-desc">
                      {{ activeNode.attributes.starts_at | date }} -
                      {{ activeNode.attributes.ends_at | date }}
                    </div>
                  </div>
                  <div class="mandatory-list">
                    <div class="mandatory-title">
                      {{ labelStatus }}
                    </div>
                    <div class="mandatory-desc">
                      {{ activeNode.attributes.status | translate }}
                    </div>
                  </div>
                </div>
              </div>

              <CustomFields
                v-if="Object.keys(customFields).length"
                :custom-fields="customFields"
              />

              <Plugins :plugins="availablePlugins" />
            </div>
          </div>
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
                      @selection="setSelection"
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
              <NodeList
                :model="model"
                :level="levelKeys"
                @selection="setSelection"
              >
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
import NodeRoot from "./components/NodeRoot";
import NodeList from "./components/NodeList";
import TableView from "./components/TableView";
import ActionLineHeader from "./components/ActionLineHeader";
import ActionLine from "./components/ActionLine";
import NumberLabel from "./components/NumberLabel";
import CustomFields from "./components/CustomFields";
import Plugins from "./components/Plugins";
import { translate, percent, date } from "lib/shared";

export default {
  name: "ByCategory",
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
    CustomFields,
    Plugins
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
      labelEnds: I18n.t("gobierto_plans.plan_types.show.ends") || "",
      labelStatus: I18n.t("gobierto_plans.plan_types.show.status") || "",
      labelProgress:
        I18n.t("gobierto_plans.plan_types.show.progress").toLowerCase() || "",
      activeNode: {},
      levelKeys: {},
      openNode: false,
      showTableHeader: false,
      jsonDepth: 0,
      customFields: {},
      availablePlugins: [],
    };
  },
  created() {
    const { level_keys, open_node, show_table_header, json_depth } = this.options;

    this.levelKeys = level_keys;
    this.openNode = open_node;
    this.showTableHeader = show_table_header;
    this.jsonDepth = +json_depth - 1;
  },
  methods: {
    setSelection(model) {
      this.activeNode = model;

      // Preprocess custom fields
      const { custom_field_records = [] } = model.attributes;
      if (custom_field_records.length > 0) {
        this.customFields = custom_field_records
      }

      // Activate plugins
      const { plugins_data = {} } = model.attributes;
      if (Object.keys(plugins_data).length) {
        this.availablePlugins = plugins_data
      }

      // TODO: avoid use uid
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
      // TODO: avoid use rootid
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
    },
    setParent() {
      // Initialize args
      var breakpoint =
        arguments.length > 0 && arguments[0] !== undefined
          ? arguments[0]
          : undefined;
      //hack 3rd level (3rd level has no SECTION)
      if (breakpoint === 3) breakpoint = breakpoint - 1;

      this.activeNode = this.getParent(breakpoint);
    }
  }
};
</script>
