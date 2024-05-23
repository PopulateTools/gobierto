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
        <ul class="planification-table planification-table--inner">
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
import { percent } from '../../../lib/vue/filters';
import GroupsByTermTableRow from '../components/GroupsByTermTableRow.vue';

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
  },
  created() {
    this.term = this.groups.find(({ key }) => key === this.id);
    this.nestedGroups = this.groups.filter(({ key }) => this.term.nestedGroups.includes(key));
  },
  methods: {
    showNestedGroups(id) {
      this.currentGroupIdOpen = this.currentGroupIdOpen === id ? null : id;
    }
  }
};
</script>
