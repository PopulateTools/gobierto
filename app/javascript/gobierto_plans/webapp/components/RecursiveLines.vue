<template>
  <ul class="lines-list">
    <li
      v-for="model in models"
      :key="model.id"
      class="mb2"
    >
      <NodeList
        :model="model"
        :max-category-level="maxCategoryLevel"
      >
        <NumberLabel
          :length="model.children.length"
          :level="model.level + 1"
        />
      </NodeList>
    </li>
  </ul>
</template>

<script>
import NodeList from './NodeList.vue';
import NumberLabel from './NumberLabel.vue';

export default {
  name: "RecursiveLines",
  components: {
    NodeList,
    NumberLabel
  },
  props: {
    models: {
      type: Array,
      default: () => []
    },
    options: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      maxCategoryLevel: 0
    }
  },
  created() {
    const { max_category_level } = this.options
    this.maxCategoryLevel = max_category_level
  }
};
</script>
