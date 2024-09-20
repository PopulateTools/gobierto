<template>
  <tr>
    <td>{{ name }}</td>
    <td>{{ startsAt | date }}</td>
    <td>{{ status }}</td>
    <td>{{ progress | percent }}</td>
  </tr>
</template>

<script>
import { date, percent } from '../../../lib/vue/filters';
import { NamesMixin } from '../lib/mixins/names';

export default {
  name: "ActionLinesTableViewRow",
  filters: {
    percent,
    date
  },
  mixins: [NamesMixin],
  props: {
    model: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      name: null,
      startsAt: null,
      status: null,
      progress: 0
    };
  },
  created() {
    const {
      attributes: { name, starts_at, status_id, progress } = {}
    } = this.model;

    this.name = name;
    this.startsAt = starts_at;
    this.status = this.getStatus(status_id);
    this.progress = progress;
  }
};
</script>
