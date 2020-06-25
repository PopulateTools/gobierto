<template>
  <div class="action-line--header node-list cat--negative">
    <div class="node-title">
      <div><i class="fas fa-caret-down" /></div>
      <h3>{{ title | translate }}</h3>
    </div>
    <NumberLabel
      :length="children.length"
      :level="level + 1"
    />
    <div>{{ progress | percent }}</div>
  </div>
</template>

<script>
import NumberLabel from "./NumberLabel";
import { percent, translate } from "lib/shared";

export default {
  name: "ActionLineHeader",
  components: {
    NumberLabel
  },
  filters: {
    percent,
    translate
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
    const { title, progress, children, level } = this.model;
    // const { attributes: { title, progress } = {}, children, level } = this.model;

    this.title = title;
    this.progress = progress;
    this.children = children;
    this.level = level;
  }
};
</script>
