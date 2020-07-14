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
          <template v-for="innerTerm in term.nestedGroups">
            <GroupsByTermTableRowRecursive
              :key="innerTerm.key"
              :term="innerTerm"
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
    term: {
      type: Object,
      default: () => []
    }
  },
  data() {
    return {
      currentGroupIdOpen: null
    };
  },
  computed: {
    ulStyles() {
      const rem = this.level + 1;
      return `margin-left: ${rem}rem; width: calc(100% - ${rem}rem)`;
    }
  },
  created() {
    const { level } = this.term;
    this.level = level;
  },
  methods: {
    showNestedGroups(id) {
      this.currentGroupIdOpen = this.currentGroupIdOpen === id ? null : id;
    }
  }
};
</script>
