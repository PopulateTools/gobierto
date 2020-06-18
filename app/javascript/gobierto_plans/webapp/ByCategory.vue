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
          :classes="[`cat_${(index % json.length) + 1}`, { 'is-root-open': parseInt(activeNode.uid) === index }]"
          :model="model"
          @selection="setSelection"
          @open-menu-mobile="openMenu = !openMenu"
        />
      </template>
    </section>

    <!-- TODO: pruebas -->
    <!-- TODO: el bucle es super falso, nunca se recorre dos veces -->
    <template v-for="i in [1, 2]">
      <section
        v-if="isOpen(i)"
        :key="i"
        :class="[`level_${i}`, `cat_${color()}`]"
      >
        <!-- TODO: Si no es el último -->
        <template v-if="i !== 2">
          <div class="node-breadcrumb mb2">
            <a
              data-turbolinks="false"
              @click.stop="resetParent"
            >
              {{ labelStarts }}
            </a>
          </div>

          <div class="lines-header">
            <NumberLabel
              :keys="levelKeys"
              :length="activeNode.children.length"
              :level="activeNode.level"
            />

            <div>{{ labelProgress }}</div>
          </div>
        </template>

        <!-- TODO: Si es el último -->
        <template v-if="i === 2">
          <div class="node-action-line">
            <div class="action-line--header node-list cat--negative">
              <div class="node-title">
                <div><i class="fas fa-caret-down" /></div>
                <h3>{{ (activeNode.attributes || {}).title | translate }}</h3>
              </div>

              <NumberLabel
                :keys="levelKeys"
                :length="activeNode.children.length"
                :level="activeNode.level"
              />

              <div>
                {{ (activeNode.attributes || {}).progress || 0 | percent }}
              </div>
            </div>

            <div class="node-action-line">
              <ul class="action-line--list">
                <li
                  v-for="(model, index) in activeNode.children"
                  :key="model.id"
                >
                  <NodeList
                    :model="model"
                    @toggle="toggle(activeNode.id, index)"
                  >
                    <NumberLabel
                      :keys="levelKeys"
                      :length="model.children.length"
                      :level="model.level"
                    />
                  </NodeList>
                  <transition name="slide-fade">
                  <!-- <TableView
                    v-if="showTable[`${activeNode.id}-${index}`]"
                    :key="model.id"
                    :model="model"
                    :header="showTableHeader"
                    :open="openNode"
                    @activate="activatePlugins"
                    @custom-fields="parseCustomFields"
                    @selection="setSelection"
                  /> -->
                  </transition>
                </li>
              </ul>
            </div>
          </div>
        </template>
        <template v-else>
          <!-- TODO: Se establece recursión, es decir, la pantalla 1, de lineas de actuacion -->
          <ul class="lines-list">
            <li
              v-for="(model, index) in activeNode.children"
              class="mb2"
            >
              <NodeList
                :key="model.id"
                :model="model"
                :level="levelKeys"
                @selection="setSelection"
              />
            </li>
          </ul>
        </template>
      </section>
    </template>

    <!-- TODO: esto es igual que dentro del bucle pero, pero este aparece cuando hay dos niveles -->
    <section
      v-if="false && isOpen(2)"
      class="level_2"
      :class="['cat_' + color() ]"
    >
      <div class="node-breadcrumb mb2">
        <a
          data-turbolinks="false"
          @click.stop="resetParent"
        >
          {{ labelStarts }}
        </a>
        <a
          data-turbolinks="false"
          @click.stop="setParent"
        >
          <i class="fas fa-caret-right" />
          {{ (getParent().attributes || {}).title | translate }}
        </a>
      </div>

      <div class="node-action-line">
        <ActionLineHeader :node="activeNode">
          <NumberLabel
            :keys="levelKeys"
            :length="activeNode.children.length"
            :level="activeNode.level"
          />
        </ActionLineHeader>

        <ul class="action-line--list">
          <li
            v-for="(model, index) in activeNode.children"
            :key="model.id"
          >
            <NodeList
              :model="model"
              :level="levelKeys"
              @toggle="toggle(activeNode.id, index)"
            />

            <transition name="slide-fade">
              <!-- <TableView
                v-if="showTable[`${activeNode.id}-${index}`]"
                :key="model.id"
                :model="model"
                :header="showTableHeader"
                :open="openNode"
                @selection="setSelection"
                @activate="activatePlugins"
                @custom-fields="parseCustomFields"
              /> -->
            </transition>
          </li>
        </ul>
      </div>
    </section>
  </div>
</template>

<script>
import NodeRoot from "./components/NodeRoot";
import NodeList from "./components/NodeList";
import TableView from "./components/TableView";
import ActionLineHeader from "./components/ActionLineHeader";
import NumberLabel from "./components/NumberLabel";
import { translate, percent } from "lib/shared";

export default {
  name: "ByCategory",
  filters: {
    translate,
    percent
  },
  components: {
    NodeRoot,
    ActionLineHeader,
    NumberLabel,
    NodeList,
    TableView
  },
  props: {
    json: {
      type: Array,
      default: () => []
    },
    levelKeys: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      openMenu: false,
      labelStarts: I18n.t("gobierto_plans.plan_types.show.starts") || '',
      labelSeeAll: I18n.t("gobierto_plans.plan_types.show.see_all") || "",
      labelProgress:
        I18n.t("gobierto_plans.plan_types.show.percentage_progress") || "",
      activeNode: {},
    };
  },
  computed: {
    // isOpenLevel0() {}
  },
  created() {
    const depth = ({ children }) => 1 + (children.length ? Math.max(...children.map(depth)) : 0)

    console.log('depth', Math.max(...this.json.map(depth)));

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
