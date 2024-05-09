<template>
  <div class="action-line--header node-list cat--negative">
    <div class="node-title">
      <div><i class="fas fa-caret-down" /></div>
      <h3>{{ title }}</h3>
    </div>
    <NumberLabel
      :length="children.length"
      :level="level + 1"
    />
    <div>{{ progress | percent }}</div>
  </div>
</template>

<script>
import { percent } from '../../../lib/vue/filters';
import NumberLabel from './NumberLabel.vue';

export default {
  name: "ActionLineHeader",
  components: {
    NumberLabel
  },
  filters: {
    percent
  },
  props: {
    model: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      title: "",
      progress: 0,
      children: [],
      level: 0
    };
  },
  created() {
    const { attributes: { name } = {}, children, level, progress } = this.model;

    this.title = name;
    this.progress = progress;
    this.children = children;
    this.level = level;
  }
};
</script>
