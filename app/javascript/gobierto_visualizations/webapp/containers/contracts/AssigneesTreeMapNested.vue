<template>
  <div>
    <TreeMapNested
      :data="data"
      :label-root-key="labelRootKey"
      :first-depth-for-tree-map="'category_title'"
      :second-depth-for-tree-map="'assignee'"
      :scale-color-key="'contract_type'"
      :treemap-id="'contracts'"
    />
  </div>
</template>
<script>

import TreeMapNested from "../../visualizations/treeMapNested.vue";

export default {
  name: 'AssigneesTreeMapNested',
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
      labelRootKey: I18n.t('gobierto_visualizations.visualizations.contracts.categories'),
    }
  }
}
</script>
