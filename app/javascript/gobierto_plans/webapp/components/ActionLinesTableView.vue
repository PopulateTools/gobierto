<template>
  <table>
    <thead v-if="header">
      <th>
        <NumberLabel :level="level + 1" />
      </th>
      <th>{{ labelStarts }}</th>
      <th>{{ labelStatus }}</th>
      <th>{{ labelProgress }}</th>
    </thead>
    <tbody>
      <ActionLinesTableViewRow
        v-for="row in children"
        :key="row.id"
        :model="row"
        :style="{ cursor: !open ? 'pointer' : '' }"
        @click.native="getProject(row)"
      />
    </tbody>
  </table>
</template>

<script>
import NumberLabel from './NumberLabel.vue';
import ActionLinesTableViewRow from './ActionLinesTableViewRow.vue';
import { routes } from '../lib/router';

export default {
  name: "ActionLinesTableView",
  components: {
    NumberLabel,
    ActionLinesTableViewRow
  },
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
    }
  },
  data() {
    return {
      labelStarts: I18n.t("gobierto_plans.plan_types.show.starts") || '',
      labelStatus: I18n.t("gobierto_plans.plan_types.show.status") || '',
      labelProgress: I18n.t("gobierto_plans.plan_types.show.progress") || '',
      children: [],
      level: 0
    };
  },
  created() {
    const { children, level } = this.model

    this.children = children
    this.level = level
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
