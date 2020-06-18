<template>
  <table>
    <thead v-if="header">
      <th><%= @plan.level_key(2, @levels + 1) %></th>
      <th>{{ labelStarts }}</th>
      <th>{{ labelStatus }}</th>
      <th>{{ labelProgress }}</th>
    </thead>
    <tbody>
      <tr
        v-for="row in model.children"
        :key="row.id"
        :style="{ cursor: !open ? 'pointer' : '' }"
        @click.stop="getProject(row)"
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
        var project = { ...row };

        this.$emit("selection", project);

        // Preprocess custom fields
        const { custom_field_records = [] } = project.attributes;
        if (custom_field_records.length > 0) {
          this.$emit("custom-fields", custom_field_records);
        }

        // Activate plugins
        const { plugins_data = {} } = project.attributes;
        if (Object.keys(plugins_data).length) {
          this.$emit("activate", plugins_data);
        }
      }
    }
  }
};
</script>
