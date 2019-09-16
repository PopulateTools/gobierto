<template>
  <nav class="investments-project-aside--steps">
    <ul>
      <li
        v-for="step in steps"
        :key="step.i"
      >
        <a href>{{ step.title }}</a>
      </li>
    </ul>
  </nav>
</template>

<script>
export default {
  name: "Steps",
  props: {
    steps: {
      type: Array,
      default: () => []
    }
  }
};
</script>