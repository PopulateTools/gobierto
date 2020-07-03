<template>
  <div>
    <div>
      <div>{{ uid }} -> {{ termId }}</div>
      <div>Personalizar columns</div>
    </div>
    <table>
      <thead>
        <template v-for="[thId, [name, , thVisibility]] in selectedColumns">
          <th
            v-if="thVisibility"
            :key="thId"
            @click="handleTableHeaderClick(thId)"
          >
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
          </th>
        </template>
      </thead>
      <tbody>
        <tr
          v-for="{ id, attributes } in projectsSorted"
          :key="id"
        >
          <template v-for="[trId, [, , trVisibility]] in selectedColumns">
            <td
              v-if="trVisibility"
              :key="trId"
            >
              {{ attributes[trId] }}
            </td>
          </template>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { NamesMixin } from "../lib/mixins/names";
import SortIcon from "../components/SortIcon";
import NumberLabel from "../components/NumberLabel";

export default {
  name: "ProjectsByTerm",
  components: {
    NumberLabel,
    SortIcon
  },
  mixins: [NamesMixin],
  props: {
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
      currentSortColumn: null
    };
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
      this.map.set(key, [this.getName(key), "up", key === 'name' || this.natives.has(key)])
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
      this.projectsSorted.sort(({ attributes: { [id]: termA } }, { attributes: { [id]: termB } }) =>
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
