<template>
  <div class="container-tree-map-nested">
    <div class="treemap-nested-sidebar">
      <div class="tree-map-nested-nav" />
      <div class="treemap-button-group button-group">
        <button
          class="button-grouped sort-G"
          :class="{ active : selected_size_entity === 'final_amount_no_taxes' }"
          @click="handleTreeMapValue('final_amount_no_taxes')"
        >
          {{ labelContractAmount }}
        </button>
        <button
          class="button-grouped sort-G"
          :class="{ active : selected_size_entity === 'number_of_contract' }"
          @click="handleTreeMapValue('number_of_contract')"
        >
          {{ labelContractTotal }}
        </button>
      </div>
    </div>
    <div class="tree-map-nested-tooltip-assignee" />
    <div class="tree-map-nested-tooltip-contracts" />
    <TreeMapNested
      :data="data"
      :label-root-key="labelRootKey"
      :size-for-treemap="'final_amount_no_taxes'"
      :first-depth-for-tree-map="'contract_type'"
      :second-depth-for-tree-map="'assignee'"
      :selected-size="selected_size_entity"
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
      svgWidth: 0,
      svgHeight: this.height,
      dataTreeMapWithoutCoordinates: undefined,
      updateData: false,
      dataForTableTooltip: undefined,
      dataNewValues: undefined,
      valueForTreemap: '',
      selected_size_entity: 'final_amount_no_taxes',
      labelContractAmount: I18n.t('gobierto_visualizations.visualizations.contracts.contract_amount'),
      labelContractTotal: I18n.t('gobierto_visualizations.visualizations.visualizations.tooltip_treemap'),
      labelRootKey: I18n.t('gobierto_visualizations.visualizations.contracts.assignees'),
    }
  },
  methods: {
    handleTreeMapValue(value) {
      if (this.selected_size_entity === value) return;
      this.selected_size_entity = value
      console.log("this.selected_size_entity", this.selected_size_entity);
    }
  }
}
</script>
