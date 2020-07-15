<template>
  <ul class="planification-table">
    <li class="planification-table__li">
      <div class="planification-table__li--content">
        <div
          v-for="[id, { name }] in columns"
          :key="id"
          class="planification-table__th"
          @click="handleTableHeaderClick(id)"
        >
          <template v-if="id === 'length'">
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
      </div>
    </li>
    <template v-for="{ key, level } in termsSorted">
      <GroupsByTermTableRowRecursive
        v-if="level === 0"
        :id="key"
        :key="key"
        :groups="groups"
      />
    </template>
  </ul>
</template>

<script>
import NumberLabel from "../components/NumberLabel";
import SortIcon from "../components/SortIcon";
import GroupsByTermTableRowRecursive from "../components/GroupsByTermTableRowRecursive";
import { NamesMixin } from "../lib/mixins/names";
import { TableHeaderMixin } from "../lib/mixins/table-header";

export default {
  name: "GroupsByTerm",
  components: {
    NumberLabel,
    SortIcon,
    GroupsByTermTableRowRecursive
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
      labelProgress: I18n.t("gobierto_plans.plan_types.show.progress") || "",
      columns: [],
      lastLevel: 0
    };
  },
  computed: {
    termsSorted() {
      const id = this.currentSortColumn;
      const sort = this.currentSort;
      return this.groups
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
    }
  },
  created() {
    const { id } = this.$route.params;
    const { last_level } = this.options;

    this.lastLevel = last_level;

    // set table columns
    this.map.set("name", { name: this.getName(id), sort: this.currentSort });
    this.map.set("progress", { name: this.labelProgress, sort:this.currentSort });
    this.map.set("length", { name: null, sort:this.currentSort });

    this.columns = Array.from(this.map);
  }
};
</script>
