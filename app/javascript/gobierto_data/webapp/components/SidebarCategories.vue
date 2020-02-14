<template>
  <div class="pure-u-1 pure-u-lg-1-4">
    <p>Categories</p>
    {{ filters }}
    <aside class="investments-home-aside--gap">
      <div
        v-for="filter in filters"
        :key="filter.key"
        class="investments-home-aside--block"
      >
        <BlockHeader
          :title="filter.title"
          :label-alt="filter.isEverythingChecked"
          class="investments-home-aside--block-header"
          see-link
          @select-all="e => handleIsEverythingChecked({ ...e, filter })"
        />
        <Checkbox
          v-for="option in filter.options"
          :id="option.id"
          :key="option.id"
          :title="option.title"
          :checked="option.isOptionChecked"
          :counter="option.counter"
          class="investments-home-aside--checkbox"
          @checkbox-change="e => handleCheckboxStatus({ ...e, filter })"
        />
      </div>
    </aside>
  </div>
</template>
<script>
import { BlockHeader, Checkbox } from "lib/vue-components";
export default {
  name: "SidebarCategories",
  components: {
    BlockHeader,
    Checkbox
  },
  props: {
    allDatasets: {
      type: Array,
      default: () => []
    },
    filters: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelSets: "",
      labelQueries: "",
      labelCategories: "",
      titleDataset: '',
      slugDataset: '',
      tableName: '',
      numberId: '',
      columns: '',
      toggle: 0,
      indexToggle: null
    }
  },
  created() {
    this.labelSets = I18n.t("gobierto_data.projects.sets")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelCategories = I18n.t("gobierto_data.projects.categories")
  },
  methods: {
    handleToggle(index) {
      this.toggle = this.toggle !== index ? index : null;
    },
    nav(slugDataset, nameDataset) {
      this.toggle = 0
      this.$router.push({
        name: "dataset",
        params: {
          id: slugDataset,
          title: nameDataset
        }
    }, () => {})
    }
  }
};
</script>
