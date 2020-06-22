<template>
  <table>
    <thead v-if="header">
      <th><slot /></th>
      <th>{{ labelStarts }}</th>
      <th>{{ labelStatus }}</th>
      <th>{{ labelProgress }}</th>
    </thead>
    <tbody>
      <tr
        v-for="row in model.children"
        :key="row.id"
        :style="{ cursor: !open ? 'pointer' : '' }"
        @click="getProject(row)"
      >
        <td>{{ row.attributes.title | translate }}</td>
        <td>{{ row.attributes.starts_at | date }}</td>
        <td>{{ row.attributes.status | translate }}</td>
        <td>{{ row.attributes.progress | percent }}</td>
      </tr>
    </tbody>
  </table>
</template>

<script>
import { percent, translate, date } from "lib/shared";

export default {
  name: "TableView",
  filters: {
    percent,
    translate,
    date
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
    };
  },
  methods: {
    getProject(row) {
      if (this.open) {
        this.$router.push({ name: 'projects', params: { ...this.$route.params, id: row.id } })
      }
    }
  }
};
</script>
