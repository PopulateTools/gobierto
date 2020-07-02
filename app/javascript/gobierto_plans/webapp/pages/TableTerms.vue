<template>
  <table>
    <th>{{ uid }}</th>
    <th>{{ labelProgress }}</th>
    <th><NumberLabel :level="lastLevel" /></th>
    <tr
      v-for="{ key, name, slug, progress, length } in groups"
      :key="key"
    >
      <td>
        <router-link :to="{ name: 'term', params: { ...params, term: slug } }">
          {{ name }}
        </router-link>
      </td>
      <td>{{ progress | percent }}</td>
      <td>{{ length }}</td>
    </tr>
  </table>
</template>

<script>
import NumberLabel from "../components/NumberLabel";
import { percent } from "lib/shared";

export default {
  name: "TableTerms",
  components: {
    NumberLabel
  },
  filters: {
    percent,
  },
  props: {
    uid: {
      type: Object,
      default: () => {}
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
      lastLevel: 0,
      labelProgress: I18n.t("gobierto_plans.plan_types.show.progress") || '',
    };
  }
};
</script>
