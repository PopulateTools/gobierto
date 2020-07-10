<template>
  <table class="planification-table">
    <thead>
      <th
        v-for="[id, [name]] in columns"
        :key="id"
        class="planification-table__th"
        @click="handleTableHeaderClick(id)"
      >
        <div class="planification-table__th-content">
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
      </th>
    </thead>
    <tbody>
      <tr
        v-for="{ key, name, slug, progress, length } in termsSorted"
        :key="key"
      >
        <td class="planification-table__td">
          <div class="planification-table__td-link">
            <i class="fas fa-caret-right" />
            <router-link
              :to="{ name: 'term', params: { ...params, term: slug } }"
            >
              {{ name }}
            </router-link>
          </div>
        </td>
        <td class="planification-table__td">
          {{ progress | percent }}
        </td>
        <td class="planification-table__td">
          {{ length }}
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>
import NumberLabel from "../components/NumberLabel";
import SortIcon from "../components/SortIcon";
import { percent } from "lib/shared";
import { NamesMixin } from "../lib/mixins/names";
import { TableHeaderMixin } from "../lib/mixins/table-header";

export default {
  name: "GroupsByTerm",
  components: {
    NumberLabel,
    SortIcon
  },
  filters: {
    percent
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
      lastLevel: 0,
    };
  },
  computed: {
    params() {
      return this.$route.params;
    },
    termsSorted() {
      const id = this.currentSortColumn;
      const sort = this.currentSort;
      return this.groups
        .slice()
        .sort(({ [id]: termA }, { [id]: termB }) =>
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
  created() {
    const { id } = this.$route.params;
    const { last_level } = this.options;

    this.lastLevel = last_level;

    // set table columns
    this.map.set("name", [this.getName(id), this.currentSort]);
    this.map.set("progress", [this.labelProgress, this.currentSort]);
    this.map.set("length", [null, this.currentSort]);

    this.columns = Array.from(this.map);
  }
};
</script>
