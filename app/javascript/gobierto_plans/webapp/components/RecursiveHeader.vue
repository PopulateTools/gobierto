<template>
  <div class="lines-header">
    <NumberLabel
      :length="children.length"
      :level="level + 1"
    />

    <div>% {{ labelProgress }}</div>
  </div>
</template>

<script>
import NumberLabel from './NumberLabel.vue';

export default {
  name: "RecursiveHeader",
  components: {
    NumberLabel
  },
  props: {
    model: {
      type: Object,
      default: () => []
    }
  },
  data() {
    return {
      labelProgress: I18n.t("gobierto_plans.plan_types.show.progress") || '',
      children: [],
      level: 0
    }
  },
  created() {
    const { children, level } = this.model

    this.children = children
    this.level = level
  }
};
</script>
