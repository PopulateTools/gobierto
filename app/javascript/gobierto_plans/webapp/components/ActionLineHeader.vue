<template>
  <div class="action-line--header node-list cat--negative">
    <div class="node-title">
      <div><i class="fas fa-caret-down" /></div>
      <h3>{{ title | translate }}</h3>
    </div>
    <slot />
    <div>{{ progress | percent }}</div>
  </div>
</template>

<script>
import { percent, translate } from "lib/shared";

export default {
  name: "ActionLineHeader",
  filters: {
    percent,
    translate
  },
  props: {
    node: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      title: "",
      progress: 0
    };
  },
  created() {
    const { attributes: { title, progress } = {} } = this.node;

    this.title = title;
    this.progress = progress;
  }
};
</script>
