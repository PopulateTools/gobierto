<template>
  <ul class="action-line--list">
    <template v-for="model in models">
      <ActionLine
        :key="model.id"
        :model="model"
        :options="options"
      >
        <ActionLinesTableView
          :key="model.id"
          :model="model"
          :header="showTableHeader"
          :open="openNode"
        />
      </ActionLine>
    </template>
  </ul>
</template>

<script>
import ActionLine from "./ActionLine";
import ActionLinesTableView from "./ActionLinesTableView";

export default {
  name: "ActionLines",
  components: {
    ActionLine,
    ActionLinesTableView
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
      children: []
    };
  },
  created() {
    const {
      open_node,
      show_table_header,
    } = this.options;

    this.openNode = open_node;
    this.showTableHeader = show_table_header;
  }
};
</script>
