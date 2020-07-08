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

export default {
  name: "GroupsByTerm",
  components: {
    NumberLabel,
    SortIcon
  },
  filters: {
    percent
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
      labelProgress: I18n.t("gobierto_plans.plan_types.show.progress") || "",
      columns: [],
      termsSorted: [],
      map: new Map(),
      lastLevel: 0,
      currentSortColumn: null
    };
  },
  computed: {
    params() {
      return this.$route.params;
    }
  },
  created() {
    const { id } = this.$route.params;
    const { last_level } = this.options;

    this.lastLevel = last_level;
    this.termsSorted = this.groups;

    // set table columns
    this.map.set("name", [this.getName(id), "up"]);
    this.map.set("progress", [this.labelProgress, "up"]);
    this.map.set("length", [null, "up"]);

    this.columns = Array.from(this.map)
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
      this.termsSorted.sort(({ [id]: termA }, { [id]: termB }) =>
        currentSort === "up" ? termA > termB : termA < termB
      );
    },
    getSorting(column) {
      // ignore the first item of the tuple
      const [, order] = this.map.get(column);
      return order;
    }
  }
};
</script>
