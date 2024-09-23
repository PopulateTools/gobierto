<template>
  <ul class="action-line--list">
    <ActionLine
      v-for="model in models"
      :key="model.id"
      :model="model"
      :options="options"
    >
      <ActionLinesTableView
        :key="model.id"
        :model="model"
        :header="showTableHeader"
        :open="openNode"
        :options="options"
      />
    </ActionLine>
  </ul>
</template>

<script>
import ActionLine from './ActionLine.vue';
import ActionLinesTableView from './ActionLinesTableView.vue';

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
