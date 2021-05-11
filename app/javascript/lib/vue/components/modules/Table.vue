<template>
  <div
    ref="table"
    class="gobierto-table"
  >
    <template v-if="showColumnSelector">
      <slot name="columns">
        <div class="gobierto-table__header">
          <TableColumnsSelector
            :columns="mapColumns"
            @visible-columns="filterColumns"
          />
        </div>
      </slot>
    </template>

    <table>
      <thead>
        <template v-for="[id, { name, index, cssClass }] in arrayColumnsFiltered">
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
        <template v-for="(item, index) in visibleRows">
          <tr
            :key="index"
            :class="{ 'is-clickable': hasPermalink }"
            class="gobierto-table__tr"
          >
            <template v-for="[id, { type, cssClass }] in arrayColumnsFiltered">
              <template v-if="type === 'money'">
                <td
                  :key="id"
                  :class="cssClass"
                  class="gobierto-table__td"
                >
                  <template v-if="hasPermalink">
                    <a
                      :href="item[href]"
                      class="gobierto-table__a"
                      @click.prevent="handleTableItem(item)"
                    >
                      {{ item[id] | money }}
                    </a>
                  </template>
                  <template v-else>
                    <span>
                      {{ item[id] | money }}
                    </span>
                  </template>
                </td>
              </template>
              <template v-else-if="type === 'date'">
                <td
                  :key="id"
                  :class="cssClass"
                  class="gobierto-table__td"
                >
                  <template v-if="hasPermalink">
                    <a
                      :href="item[href]"
                      class="gobierto-table__a"
                      @click.prevent="handleTableItem(item)"
                    >
                      {{ item[id] | date }}
                    </a>
                  </template>
                  <template v-else>
                    <span>
                      {{ item[id] | date }}
                    </span>
                  </template>
                </td>
              </template>
              <template v-else-if="type === 'truncate'">
                <td
                  :key="id"
                  class="gobierto-table__td"
                >
                  <template v-if="hasPermalink">
                    <a
                      :href="item[href]"
                      class="gobierto-table__a"
                      :class="cssClass"
                      @click.prevent="handleTableItem(item)"
                    >
                      {{ item[id] }}
                    </a>
                  </template>
                  <template v-else>
                    <span :class="cssClass">
                      {{ item[id] }}
                    </span>
                  </template>
                </td>
              </template>
              <template v-else>
                <td
                  :key="id"
                  :class="cssClass"
                  class="gobierto-table__td"
                >
                  <template v-if="hasPermalink">
                    <a
                      :href="item[href]"
                      class="gobierto-table__a"
                      @click.prevent="handleTableItem(item)"
                    >
                      {{ item[id] }}
                    </a>
                  </template>
                  <template v-else>
                    <span>
                      {{ item[id] }}
                    </span>
                  </template>
                </td>
              </template>
            </template>
          </tr>
        </template>
      </tbody>
    </table>
    <template v-if="showPagination">
      <slot
        name="pagination"
        :paginator="updateData"
        :data="rowsSorted"
      >
        <Pagination
          :data="rowsSorted"
          :items-per-page="25"
          :container-pagination="'main'"
          @showData="updateData"
        />
      </slot>
    </template>
  </div>
</template>
<script>
import { Pagination } from "lib/vue/components"
import { VueFiltersMixin } from "lib/vue/filters"
import TableColumnsSelector from './TableColumnsSelector'
import SortIcon from './SortIcon'

const collator = new Intl.Collator(I18n.locale)

export default {
  name: 'Table',
  components: {
    SortIcon,
    TableColumnsSelector,
    Pagination,
  },
  mixins: [VueFiltersMixin],
  defaults: {
    sortColumn: "id",
    sortDirection: "asc",
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
    sortColumn: {
      type: String,
      default: null
    },
    sortDirection: {
      type: String,
      default: null
    },
    showColumns: {
      type: Array,
      default: () => []
    },
    showColumnSelector: {
      type: Boolean,
      default: true
    },
    showPagination: {
      type: Boolean,
      default: true
    },
    href: {
      type: String,
      default: 'href'
    },
  },
  data() {
    return {
      mapColumns: new Map(),
      currentSortColumn: this.sortColumn || this.$options.defaults.sortColumn,
      currentSort: this.sortDirection || this.$options.defaults.sortDirection,
      visibleColumns: this.showColumns.length ? this.showColumns : this.columns.map(({ field }) => field),
      visiblePaginatedRows: null,
      arrayColumnsFiltered: []
    };
  },
  computed: {
    hasPermalink() {
      return this.data.some(element => element[this.href])
    },
    rowsSorted() {
      const id = this.currentSortColumn;
      const sort = this.currentSort;
      return this.data
        .slice()
        .sort(({ [id]: termA }, { [id]: termB }) =>
          sort === "asc"
            ? typeof termA === "string"
              ? collator.compare(termA, termB)
              : termA > termB ? 1 : -1
            : typeof termA === "string"
              ? collator.compare(termB, termA)
              : termA < termB ? 1 : -1
        );
    },
    visibleRows() {
      // if there's pagination, display only such subset, otherwise show everything
      return this.showPagination ? this.visiblePaginatedRows : this.rowsSorted
    },
  },
  created() {
    this.prepareTable()
  },
  methods: {
    handleTableHeaderClick(id) {
      const { sort } = this.mapColumns.get(id);
      this.currentSortColumn = id;
      // toggle sort order
      this.currentSort = sort === "asc" ? "desc" : "asc";
      // update the order for the item clicked
      this.mapColumns.set(id, { ...this.mapColumns.get(id), sort: this.currentSort });
    },
    getSorting(column) {
      // ignore the first item of the tuple
      const { sort } = this.mapColumns.get(column)
      return sort;
    },
    prepareTable() {
      this.mapColumns.clear();
      for (let index = 0; index < this.columns.length; index++) {
        const { field, name, type, cssClass = '' } = this.columns[index];
        this.mapColumns.set(field, {
          visibility: this.visibleColumns.includes(field),
          name: name,
          sort: field === this.currentSortColumn ? this.currentSort : undefined,
          type: type,
          cssClass: cssClass
        });
      }
      this.arrayColumnsFiltered = Array.from(this.mapColumns).filter(([,{ visibility }]) => !!visibility)
    },
    updateData(values) {
      this.visiblePaginatedRows = values
    },
    filterColumns(columns) {
      this.mapColumns = columns
      this.arrayColumnsFiltered = Array.from(this.mapColumns).filter(([,{ visibility }]) => !!visibility)
    },
    handleTableItem(item) {
      this.$emit('on-href-click', item)
    }
  }
}
</script>
