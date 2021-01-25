<template>
  <div
    data-testid="table-component"
    class="gobierto-table"
  >
    <div class="gobierto-table__header">
      <slot name="title" />
      <slot
        name="columns"
        :toggle-visibility="toggleVisibility"
      />
    </div>
    <table>
      <thead>
        <template v-for="[id, { name, index, cssClass }] in columnsMapArr">
          <th
            :key="index"
            class="gobierto-table__th"
            :class="cssClass"
            @click="handleTableHeaderClick(id)"
          >
            {{ name }}
            <SortIcon
              v-if="currentSortColumn === id"
              :direction="getSorting(id)"
            />
          </th>
        </template>
      </thead>
      <tbody>
        <template
          v-for="(item, index) in dataTable"
        >
          <router-link
            :key="index"
            :to="{ name: routingMember, params: {id: item[routingId] } }"
            tag="tr"
            class="gobierto-table__tr"
          >
            <template
              v-for="{key, field, type, cssClass} in filterColumns"
            >
              <template v-if="type === 'money'">
                <td
                  :key="key"
                  :class="cssClass"
                  class="gobierto-table__td"
                >
                  <span>
                    {{ money(item[field]) }}
                  </span>
                </td>
              </template>
              <template v-else-if="type === 'date'">
                <td
                  :key="key"
                  :class="cssClass"
                  class="gobierto-table__td"
                >
                  <span>
                    {{ item[field] }}
                  </span>
                </td>
              </template>
              <template v-else-if="type === 'link'">
                <td
                  :key="key"
                  :class="cssClass"
                  class="gobierto-table__td"
                >
                  <span>
                    <a href="#">{{ item[field] }}</a>
                  </span>
                </td>
              </template>
              <template v-else-if="type === 'truncate'">
                <td
                  :key="key"
                  class="gobierto-table__td"
                >
                  <span :class="cssClass">
                    {{ item[field] }}
                  </span>
                </td>
              </template>
              <template v-else>
                <td
                  :key="key"
                  :class="cssClass"
                  class="gobierto-table__td"
                >
                  <span>{{ item[field] }}</span>
                </td>
              </template>
            </template>
          </router-link>
        </template>
      </tbody>
    </table>
    <Pagination
      :data="rowsSorted"
      :items-per-page="itemsPerPage"
      :container-pagination="containerPagination"
      @showData="updateData"
    />
  </div>
</template>
<script>

import Pagination from "./Pagination.vue";
import SortIcon from "./SortIcon.vue"
import { VueFiltersMixin } from "lib/vue/filters"
export default {
  name: 'Table',
  components: {
    SortIcon,
    Pagination
  },
  mixins: [VueFiltersMixin],
  defaults: {
    sortColumn: "id",
    sortDirection: "up",
  },
  props: {
    data: {
      type: Array,
      default: () => []
    },
    columns: {
      type: Array,
      default: () => []
    },
    orderColumn: {
      type: String,
      default: ''
    },
    showColumns: {
      type: Array,
      default: () => []
    },
    routingMember: {
      type: String,
      default: ''
    },
    routingId: {
      type: String,
      default: ''
    },
    paginationId: {
      type: String,
      default: ''
    },
    itemsPerPage: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      map: new Map(),
      currentSortColumn: this.$options.defaults.sortColumn,
      currentSort: this.$options.defaults.sortDirection,
      visibleColumns: this.showColumns,
      filterColumns: [],
      dataTable: [],
      containerPagination: this.paginationId
    };
  },
  computed: {
    tmpRows() {
      return this.data || []
    },
    rowsSorted() {
      const id = this.currentSortColumn.field || this.orderColumn;
      const sort = this.currentSort;
      return this.tmpRows
        .slice()
        .sort(({ [id]: termA }, { [id]: termB }) =>
          sort === "up"
            ? typeof termA === "string"
              ? termA.localeCompare(termB, undefined, { numeric: true })
              : termA > termB ? -1 : 1
            : typeof termA === "string"
              ? termB.localeCompare(termA, undefined, { numeric: true })
              : termA < termB ? -1 : 1
        );
    },
    icon() {
      return this.direction === 'down' ? 'down' : 'down-alt'
    }
  },
  created() {
    this.prepareTable()
  },
  methods: {
    handleTableHeaderClick(id) {
      const { sort } = this.map.get(id);
      this.currentSortColumn = id;
      // toggle sort order
      this.currentSort = sort === "up" ? "down" : "up";
      // update the order for the item clicked
      this.map.set(id, { ...this.map.get(id), sort: this.currentSort });
    },
    getSorting(column) {
      // ignore the first item of the tuple
      const { sort } = this.map.get(column)
      return sort;
    },
    prepareTable() {
      this.filterColumns = this.columns.filter(({ field }) => this.visibleColumns.includes(field))
      this.map.clear();
      for (let index = 0; index < this.filterColumns.length; index++) {
        const column = this.filterColumns[index];
        this.map.set(column, {
          visibility: this.visibleColumns.includes(column.field),
          name: column.name,
          sort: undefined,
          type: column.type,
          cssClass: column.cssClass
        });
      }
      this.columnsMapArr = Array.from(this.map);
    },
    toggleVisibility({ id, value }) {
      const columns = this.columns.map(({ field }) => field)
      const columnName = columns[columns.findIndex((x, index) => index === id)]
      if (value) {
        this.visibleColumns.push(columnName)
      } else {
        this.visibleColumns = this.visibleColumns.filter(item => item !== columnName)
      }
      this.prepareTable()
      this.$emit('update-show-columns', this.visibleColumns)
    },
    updateData(values) {
      this.dataTable = values
    },
  }
}
</script>
