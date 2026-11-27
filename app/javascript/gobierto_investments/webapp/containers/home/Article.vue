<template>
  <div class="investments-home-article--container">
    <Phase
      v-for="(phase, i) in phases"
      :key="phase.id"
      :title="phase.title"
      :count="phase.count"
      :budget="phase.budget | money"
      :projects="phase.items"
      :is-negative="i > 3"
    />
  </div>
</template>

<script>
import Phase from '../../components/Phase.vue';
import { CommonsMixin } from '../../mixins/common.js';

export default {
  name: "HomeArticle",
  components: {
    Phase
  },
  mixins: [CommonsMixin],
  props: {
    phases: {
      type: Array,
      default: () => []
    }
  }
};
</script>
