<template>
  <nav class="investments-project-aside--steps">
    <ul>
      <li
        v-for="step in steps"
        :key="step.id"
      >
        <a href>{{ step.title | translate }}</a>
      </li>
    </ul>
  </nav>
</template>

<script>
import { CommonsMixin } from "../mixins/common.js";

export default {
  name: "Steps",
  mixins: [CommonsMixin],
  props: {
    steps: {
      type: Array,
      default: () => []
    }
  }
};
</script>