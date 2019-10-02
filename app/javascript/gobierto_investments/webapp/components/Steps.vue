<template>
  <nav class="investments-project-aside--steps">
    <ul>
      <li
        v-for="step in steps"
        :key="step.id"
      >
        <span :class="{ 'is-active': step.active }">{{ step.title | translate }}</span>
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