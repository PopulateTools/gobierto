<template>
  <div>
    <TreeMapNested
      :data="data"
      :label-root-key="labelRootKey"
      :first-depth-for-tree-map="'contractor'"
      :second-depth-for-tree-map="'assignee'"
      :scale-color-key="'contractor'"
      :treemap-id="'entity'"
    />
  </div>
</template>
<script>

import TreeMapNested from "../../visualizations/treeMapNested.vue";

export default {
  name: 'EntityTreeMapNested',
  components: {
    TreeMapNested
  },
  props: {
    data: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelRootKey: I18n.t('gobierto_visualizations.visualizations.contracts.entities') || '',
    }
  }
}
</script>
