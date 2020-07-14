<template>
  <li class="planification-table__li">
    <GroupsByTermTableRow
      :key="term.key"
      :is-open="currentGroupIdOpen === term.key"
      :term="term"
      @show-nested-groups="showNestedGroups"
    />

    <transition
      :key="term.key"
      name="slide"
    >
      <template v-if="currentGroupIdOpen === term.key">
        <ul
          class="planification-table"
          :style="ulStyles"
        >
          <template v-for="{ key, level } in nestedGroups">
            <GroupsByTermTableRowRecursive
              v-if="nextLevel === level"
              :id="key"
              :key="key"
              :groups="groups"
            />
          </template>
        </ul>
      </template>
    </transition>
  </li>
</template>

<script>
import { percent } from "lib/shared";
import GroupsByTermTableRow from "../components/GroupsByTermTableRow";

export default {
  name: "GroupsByTermTableRowRecursive",
  components: {
    GroupsByTermTableRow
  },
  filters: {
    percent
  },
  props: {
    id: {
      type: String,
      default: null
    },
    groups: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      term: {},
      nestedGroups: [],
      currentGroupIdOpen: null
    };
  },
  computed: {
    nextLevel() {
      return this.term.level + 1;
    },
    ulStyles() {
      return `margin-left: ${this.nextLevel}rem; width: calc(100% - ${
        this.nextLevel
      }rem)`;
    }
  },
  created() {
    // TODO: repasar
    const [term, nestedGroups] = this.groups.reduce(
      (acc, item) => {
        if (item.key === this.id) acc[0] = item;
        if (acc[0] && acc[0].nestedGroups.includes(item.key)) acc[1].push(item);
        return acc;
      },
      [null, []]
    );

    this.term = term;
    this.nestedGroups = nestedGroups;
  },
  methods: {
    showNestedGroups(id) {
      this.currentGroupIdOpen = this.currentGroupIdOpen === id ? null : id;
    }
  }
};
</script>
