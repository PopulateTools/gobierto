<template>
  <div class="planification-table__container">
    <div class="planification-table__header">
      <TableBreadcrumb :groups="groups" />
      <TableColumnsSelector
        v-clickoutside="hideTableColumnsSelector"
        :columns="selectedColumns"
        @toggle-visibility="toggleVisibility"
      />
    </div>

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
            :project-id="id"
            :marked="currentId === id"
            :columns="selectedColumns"
            :attributes="attributes"
            @show-project="setCurrentProject"
          />
        </template>
      </tbody>

      <transition name="fade">
        <section
          v-if="activeNode"
          class="planification-floating-project category"
          :style="`--category: var(--category-${currentRootid})`"
        >
          <Project
            :key="currentId"
            :model="activeNode"
            :options="options"
          />
        </section>
      </transition>
    </table>
  </div>
</template>

<script>
import { NamesMixin } from "../lib/mixins/names";
import { findRecursive } from "../lib/helpers";
import SortIcon from "../components/SortIcon";
import NumberLabel from "../components/NumberLabel";
import Project from "../components/Project";
import ProjectsByTermTableRow from "../components/ProjectsByTermTableRow";
import TableBreadcrumb from "../components/TableBreadcrumb";
import TableColumnsSelector from "../components/TableColumnsSelector";
import { clickoutside } from "lib/shared"

export default {
  name: "ProjectsByTerm",
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
  mixins: [NamesMixin],
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
      projectsSorted: [],
      map: new Map(),
      mapTracker: 1,
      currentSortColumn: null,
      activeNode: null,
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
    }
  },
  created() {
    const { term } = this.$route.params;
    const { children } = this.groups.find(({ slug }) => slug === term);
    const { last_level } = this.options;

    this.lastLevel = last_level;
    this.projectsSorted = children;

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
          "up",
          this.natives.has(key)
        ]);
      }
    });
  },
  methods: {
    handleTableHeaderClick(id) {
      const [name, order] = this.map.get(id);
      this.currentSortColumn = id;

      // toggle sort order
      const currentSort = order === "up" ? "down" : "up";
      // update the order for the item clicked
      this.map.set(id, [name, currentSort]);
      // change the order based on the currentSort
      this.projectsSorted.sort(
        ({ attributes: { [id]: termA } }, { attributes: { [id]: termB } }) =>
          currentSort === "up" ? termA > termB : termA < termB
      );
    },
    getSorting(column) {
      // ignore the first item of the tuple
      const [, order] = this.map.get(column);
      return order;
    },
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
      // TODO: repasar esto
      if (this.activeNode) {
        this.activeNode = null
      }
    },
    hideTableColumnsSelector() {}
  }
};
</script>
