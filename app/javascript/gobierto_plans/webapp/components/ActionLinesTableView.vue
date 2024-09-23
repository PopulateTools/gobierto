<template>
  <table>
    <thead v-if="header">
      <th>
        <NumberLabel :level="level + 1" />
      </th>
      <th
        v-for="[key, value] in tableHeaders"
        :key="key"
      >
        {{ value }}
      </th>
    </thead>
    <tbody>
      <ActionLinesTableViewRow
        v-for="row in children"
        :key="row.id"
        :model="row"
        :default-table-fields="defaultTableFields"
        :options="options"
        :style="{ cursor: !open ? 'pointer' : '' }"
        @click.native="getProject(row)"
      />
    </tbody>
  </table>
</template>

<script>
import NumberLabel from './NumberLabel.vue';
import ActionLinesTableViewRow from './ActionLinesTableViewRow.vue';
import { NamesMixin } from '../lib/mixins/names';
import { routes } from '../lib/router';

export default {
  name: "ActionLinesTableView",
  components: {
    NumberLabel,
    ActionLinesTableViewRow
  },
  mixins: [NamesMixin],
  props: {
    model: {
      type: Object,
      default: () => {}
    },
    header: {
      type: Boolean,
      default: false
    },
    open: {
      type: Boolean,
      default: false
    },
    options: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      children: [],
      level: 0,
      tableHeaders: [],
      defaultTableFields: ["starts_at", "status", "progress"]
    };
  },
  created() {
    const { children, level } = this.model
    const {
      show_table_extra_fields = this.defaultTableFields
    } = this.options;

    this.children = children
    this.level = level
    this.tableHeaders = show_table_extra_fields.map(key => [key, this.getName(key)])
  },
  methods: {
    getProject(row) {
      if (this.open) {
        this.$router.push({ name: routes.PROJECTS, params: { ...this.$route.params, id: row.id } })
      }
    }
  }
};
</script>
