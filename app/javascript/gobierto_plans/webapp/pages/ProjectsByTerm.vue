<template>
  <div class="planification-table__container">
    <div class="planification-table__header">
      <div class="planification-table__breadcrumb">
        <span class="planification-table__breadcrumb-group">
          {{ uid }}
        </span>
        <i class="planification-table__breadcrumb-arrow fas fa-arrow-right" />
        <router-link
          :to="{ name: 'table', params: { ...params } }"
          class="planification-table__breadcrumb-term"
        >
          <span>{{ termId }}</span>
          <i class="planification-table__breadcrumb-times fas fa-times" />
        </router-link>
      </div>
      <div style="opacity: 0.25">
        <!-- TODO: completar -->
        Personalizar columns
      </div>
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

export default {
  name: "ProjectsByTerm",
  components: {
    NumberLabel,
    SortIcon,
    ProjectsByTermTableRow,
    Project
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
      termId: null,
      lastLevel: 0,
      projectsSorted: [],
      selectedColumns: [],
      map: new Map(),
      currentSortColumn: null,
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
    }
  },
  created() {
    const { id, term } = this.$route.params;
    const { name, children } = this.groups.find(({ slug }) => slug === term);
    const { last_level } = this.options;

    this.lastLevel = last_level;
    this.termId = name;
    this.uid = this.getName(id);
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
    keys.forEach(key =>
      // for each key, we store the traslation, the sorting direction, and the visibility
      this.map.set(key, [
        this.getName(key),
        "up",
        key === "name" || this.natives.has(key)
      ])
    );
    this.selectedColumns = Array.from(this.map);
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
    hey() {
      console.log('jo');

    }
  }
};
</script>
