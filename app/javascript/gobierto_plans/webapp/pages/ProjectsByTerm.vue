<template>
  <div class="planification-table__container">
    <div class="planification-table__header">
      <TableBreadcrumb :groups="groups" />
      <TableColumnsSelector
        :columns="selectedColumns"
        @toggle-visibility="toggleVisibility"
      />
    </div>

    <div class="planification-table__wrapper">
      <div>
        <table class="planification-table">
          <thead>
            <template v-for="[thId, [name, , thVisibility]] in selectedColumns">
              <th
                v-if="thVisibility"
                :key="thId"
                class="planification-table__th"
                @click="handleTableHeaderClick(thId)"
              >
                <div class="planification-table__th-content">
                  <template v-if="thId === 'name'">
                    <NumberLabel :level="lastLevel" />
                  </template>
                  <template v-else>
                    {{ name }}
                  </template>

                  <SortIcon
                    v-if="currentSortColumn === thId"
                    :direction="getSorting(thId)"
                  />
                </div>
              </th>
            </template>
          </thead>
          <tbody>
            <template v-for="{ id, attributes } in projectsSorted">
              <ProjectsByTermTableRow
                :key="id"
                v-slot="{ column }"
                :marked="currentId === id"
                :columns="selectedColumns"
              >
                <template v-if="column === 'name'">
                  <div
                    class="planification-table__td-name"
                    @click="setCurrentProject(id)"
                  >
                    {{ attributes[column] }}
                  </div>
                </template>
                <template v-else-if="column === 'progress'">
                  {{ attributes[column] | percent }}
                </template>
                <template v-else>
                  {{ attributes[column] }}
                </template>
              </ProjectsByTermTableRow>
            </template>
          </tbody>
        </table>
      </div>

      <transition name="fade">
        <section
          v-if="activeNode"
          class="planification-floating-project category"
          :style="`--category: var(--category-${currentRootid})`"
        >
          <Project
            :key="currentId"
            v-clickoutside="hideProject"
            :model="activeNode"
            :options="options"
          >
            <div
              class="planification-floating-project__times"
              @click="hideProject"
            >
              <i class="fas fa-times" />
            </div>
          </Project>
        </section>
      </transition>
    </div>
  </div>
</template>

<script>
import { NamesMixin } from "../lib/mixins/names";
import { TableHeaderMixin } from "../lib/mixins/table-header";
import { findRecursive } from "../lib/helpers";
import SortIcon from "../components/SortIcon";
import NumberLabel from "../components/NumberLabel";
import Project from "../components/Project";
import ProjectsByTermTableRow from "../components/ProjectsByTermTableRow";
import TableBreadcrumb from "../components/TableBreadcrumb";
import TableColumnsSelector from "../components/TableColumnsSelector";
import { percent, clickoutside } from "lib/shared"

export default {
  name: "ProjectsByTerm",
  filters: {
    percent
  },
  components: {
    NumberLabel,
    SortIcon,
    ProjectsByTermTableRow,
    Project,
    TableBreadcrumb,
    TableColumnsSelector
  },
  directives: {
    clickoutside
  },
  mixins: [NamesMixin, TableHeaderMixin],
  props: {
    json: {
      type: Array,
      default: () => []
    },
    groups: {
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
      lastLevel: 0,
      children: [],
      mapTracker: 1,
      activeNode: null
    };
  },
  computed: {
    params() {
      return this.$route.params;
    },
    currentRootid() {
      const { rootid } = this.activeNode || {};
      return rootid + 1;
    },
    currentId() {
      const { id } = this.activeNode || {};
      return id;
    },
    selectedColumns() {
      return this.mapTracker && Array.from(this.map)
    },
    projectsSorted() {
      const id = this.currentSortColumn;
      const sort = this.currentSort;
      return this.children
        .slice()
        .sort(({ attributes: { [id]: termA } }, { attributes: { [id]: termB } }) =>
          sort === "up"
            ? typeof termA === "string"
              ? termA.localeCompare(termB)
              : termA > termB
            : typeof termA === "string"
              ? termB.localeCompare(termA)
              : termA < termB
        );
    }
  },
  watch: {
    activeNode(newVal, oldVal) {
      /**
       * disable directive in two cases:
       * 1. there's no former activeNode, i.e. Project component is unmounted
       * 2. both newVal and oldVal has value, i.e. it's clicking in a different project
       */
      this.disableClickOutsideDirective = (oldVal === null || (newVal && oldVal))
    }
  },
  created() {
    const { term } = this.$route.params;
    const { children } = this.groups.find(({ slug }) => slug === term);
    const { last_level } = this.options;

    this.lastLevel = last_level;
    this.children = children;

    // get the object with the biggest amount of attributes (they'll be the available columns)
    const { attributes } = children.reduce((a, b) =>
      Object.keys(a.attributes).length > Object.keys(b.attributes).length
        ? a
        : b
    );

    // if exists, move the column called 'progress' to the end of the list
    const keys = Object.keys(attributes);
    if (keys.includes("progress")) {
      keys.push(keys.splice(keys.indexOf("progress"), 1)[0]);
    }

    // initialize a map to handle the columns
    keys.forEach(key => {
      // for each key, we store the traslation, the sorting direction, and the visibility
      const name = this.getName(key);
      if (name) {
        this.map.set(key, [
          name,
          this.currentSort,
          this.natives.has(key)
        ]);
      }
    });
  },
  methods: {
    setCurrentProject(id) {
      const { id: prevId } = this.activeNode || {};
      this.activeNode = id === prevId ? null : findRecursive(this.json, id);
    },
    toggleVisibility({ id, value }) {
      const [name,order] = this.map.get(id)
      this.map.set(id, [name, order, value])

      // https://stackoverflow.com/a/45441321/5020256
      this.mapTracker += 1;
    },
    hideProject() {
      // If the directive is not disable, we clean the activeNode, otherwise, we activate it
      if (!this.disableClickOutsideDirective) {
        this.activeNode = null
      } else {
        this.disableClickOutsideDirective = false
      }
    }
  }
};
</script>
