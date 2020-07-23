<template>
  <tr>
    <td>{{ name }}</td>
    <td>{{ startsAt | date }}</td>
    <td>{{ status }}</td>
    <td>{{ progress | percent }}</td>
  </tr>
</template>

<script>
import { PlansStore } from "../lib/store";
import { percent, date } from "lib/shared";

export default {
  name: "ActionLinesTableViewRow",
  filters: {
    percent,
    date
  },
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
    const { status } = PlansStore.state;
    const { attributes: { name: statusText } = {} } = status.find(({ id }) => +id === +status_id) || {};

    this.name = name;
    this.startsAt = starts_at;
    this.status = statusText;
    this.progress = progress;
  }
};
</script>
