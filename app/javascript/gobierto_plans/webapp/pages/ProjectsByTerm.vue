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
        <ul class="planification-table">
          <li class="planification-table__li">
            <div class="planification-table__li--content">
              <template v-for="[id, { name, visibility }] in selectedColumns">
                <div
                  v-if="visibility"
                  :key="id"
                  class="planification-table__th"
                  @click="handleTableHeaderClick(id)"
                >
                  <template v-if="id === 'name'">
                    <NumberLabel :level="lastLevel" />
                  </template>
                  <template v-else>
                    {{ name }}
                  </template>

                  <SortIcon
                    v-if="currentSortColumn === id"
                    :direction="getSorting(id)"
                  />
                </div>
              </template>
            </div>
          </li>
          <template v-for="{ id, attributes } in projectsSorted">
            <ProjectsByTermTableRow
              :key="id"
              v-slot="{ column, options }"
              :marked="currentId === id"
              :columns="selectedColumns"
            >
              <TableCellTemplates
                :column="column"
                :attributes="{ ...options, id, value: attributes[column] }"
                @current-project="setCurrentProject"
              />
            </ProjectsByTermTableRow>
          </template>
        </ul>
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
import { NamesMixin } from '../lib/mixins/names';
import { TableHeaderMixin } from '../lib/mixins/table-header';
import { findRecursive } from '../lib/helpers';
import SortIcon from '../components/SortIcon.vue';
import NumberLabel from '../components/NumberLabel.vue';
import Project from '../components/Project.vue';
import ProjectsByTermTableRow from '../components/ProjectsByTermTableRow.vue';
import TableBreadcrumb from '../components/TableBreadcrumb.vue';
import TableColumnsSelector from '../components/TableColumnsSelector.vue';
import TableCellTemplates from '../components/TableCellTemplates.vue';
import { percent } from '../../../lib/vue/filters'
import { clickoutside } from '../../../lib/vue/directives'

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
    TableColumnsSelector,
    TableCellTemplates
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
        this.map.set(key, {
          name,
          sort: this.currentSort,
          visibility: this.natives.has(key),
          options: this.getAttributes(key)
        });
      }
    });
  },
  methods: {
    setCurrentProject(id) {
      const { id: prevId } = this.activeNode || {};
      this.activeNode = id === prevId ? null : findRecursive(this.json, id);
    },
    toggleVisibility({ id, value }) {
      this.map.set(id, { ...this.map.get(id), visibility: value })
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
