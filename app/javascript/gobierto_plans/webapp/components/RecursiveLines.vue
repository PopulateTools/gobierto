<template>
  <ul class="lines-list">
    <li
      v-for="model in models"
      :key="model.id"
      class="mb2"
    >
      <NodeList :model="model">
        <NumberLabel
          :length="model.children.length"
          :level="model.level + 1"
        />
      </NodeList>
    </li>
  </ul>
</template>

<script>
import NodeList from "./NodeList";
import NumberLabel from "./NumberLabel";

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
    }
  }
};
</script>
