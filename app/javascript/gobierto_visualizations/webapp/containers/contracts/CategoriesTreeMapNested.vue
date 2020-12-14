<template>
  <div>
    <TreeMapNested
      :data="data"
      :root-data="rootData"
      :label-root-key="labelRootKey"
      :first-depth-for-tree-map="'category_title'"
      :second-depth-for-tree-map="'assignee'"
      :scale-color-key="'contract_type'"
      :treemap-id="'contracts'"
      @transformData="nestedData"
    />
  </div>
</template>
<script>
import { nest } from "d3-collection";
import TreeMapNested from "../../visualizations/treeMapNested.vue";

export default {
  name: 'CategoriesTreeMapNested',
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
      rootData: {}
    }
  },
  methods: {
    nestedData(data, sizeForTreemap) {
      let dataFilter = data
      dataFilter.filter(contract => contract.final_amount_no_taxes !== 0)
      dataFilter.forEach(d => {
        d.number_of_contract = 1
      })
      // d3v6
      //
      // const dataGroupTreeMap = Array.from(
      //   d3.group(data, d =>  d.contract_type, d.assignee),
      // );
      const nested_data = nest()
        .key(d => d['category_title'])
        .key(d => d['assignee'])
        .entries(dataFilter);
      let rootData = {};

      rootData.key = this.labelRootKey
      rootData.values = nested_data;

      rootData = replaceDeepKeys(rootData, sizeForTreemap);
      //d3 Nest add names to the keys that are not valid to build a treemap, we need to replace them
      function replaceDeepKeys(root, value_key) {
        for (var key in root) {
          if (key === "key") {
            root.name = root.key;
            delete root.key;
          }
          if (key === "values") {
            root.children = [];
            for (key in root.values) {
              root.children.push(replaceDeepKeys(root.values[key], value_key));
            }
            delete root.values;
          }
          if (key === value_key) {
            root.value = parseFloat(root[value_key]);
            delete root[value_key];
          }
        }
        return root;
      }
      this.rootData = rootData
    }
  }
}
</script>
