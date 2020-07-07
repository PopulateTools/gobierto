<template>
  <div style="width: 100%">
    <div>
      <div>{{ uid }} -> {{ termId }}</div>
      <div>Personalizar columns</div>
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

      <section
        v-if="activeNode"
        class="category"
        :style="`--category: var(--category-${currentRootid})`"
      >
        <Project
          :key="currentId"
          :model="activeNode"
          :options="options"
        />
      </section>
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

    // get the object with the biggest amount of attributes
    const { attributes } = children.reduce((a, b) =>
      Object.keys(a.attributes).length > Object.keys(b.attributes).length
        ? a
        : b
    );

    // initialize a map to handle the columns
    // for each key, we store the traslation, the sorting direction, and the visibility
    Object.keys(attributes).forEach(key =>
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
      const { id: prevId } = this.activeNode || {}
      console.log(prevId, this.activeNode);

      this.activeNode = (id === prevId) ? null : findRecursive(this.json, id);
    }
  }
};
</script>
