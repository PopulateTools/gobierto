<template>
  <table>
    <thead>
      <th @click="handleTableHeaderClick(1)">
        {{ uid }}
        <SortIcon
          v-if="currentSortColumn === 1"
          :direction="getDirection(1)"
        />
      </th>
      <th @click="handleTableHeaderClick(2)">
        {{ labelProgress }}
        <SortIcon
          v-if="currentSortColumn === 2"
          :direction="getDirection(2)"
        />
      </th>
      <th @click="handleTableHeaderClick(3)">
        <NumberLabel :level="lastLevel" />
        <SortIcon
          v-if="currentSortColumn === 3"
          :direction="getDirection(3)"
        />
      </th>
    </thead>
    <tbody>
      <tr
        v-for="{ key, name, slug, progress, length } in termsSorted"
        :key="key"
      >
        <td>
          <router-link
            :to="{ name: 'term', params: { ...params, term: slug } }"
          >
            {{ name }}
          </router-link>
        </td>
        <td>{{ progress | percent }}</td>
        <td>{{ length }}</td>
      </tr>
    </tbody>
  </table>
</template>

<script>
import NumberLabel from "../components/NumberLabel";
import SortIcon from "../components/SortIcon";
import { percent } from "lib/shared";

export default {
  name: "TableTerms",
  components: {
    NumberLabel,
    SortIcon
  },
  filters: {
    percent
  },
  props: {
    uid: {
      type: String,
      default: ""
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
    const { last_level } = this.options;
    this.lastLevel = last_level;
    this.termsSorted = this.groups;

    this.map.set(1, ["name", "up"]);
    this.map.set(2, ["progress", "up"]);
    this.map.set(3, ["length", "up"]);
  },
  methods: {
    handleTableHeaderClick(column) {
      const [id, order] = this.map.get(column);
      this.currentSortColumn = column

      // toggle sort order
      const currentSort = order === "up" ? "down" : "up";
      // update the order for the item clicked
      this.map.set(column, [id, currentSort]);
      // change the order based on the currentSort
      this.termsSorted.sort(({ [id]: termA }, { [id]: termB }) =>
        currentSort === "up" ? termA > termB : termA < termB
      );
    },
    getDirection(column) {
      const [_, order] = this.map.get(column);
      return order;
    }
  }
};
</script>
