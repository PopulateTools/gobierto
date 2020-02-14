<template>
  <div>
    <div
      v-for="(item, index) in allDatasets"
      :key="index"
      class="gobierto-data-sidebar-datasets"
    >
      <div class="gobierto-data-sidebar-datasets-links-container">
        <i
          :class="{'rotate-caret': toggle !== index }"
          class="fas fa-caret-down gobierto-data-sidebar-icon"
          @click="handleToggle(index)"
        />
        <a
          :href="'/datos/' + item.attributes.slug"
          class="gobierto-data-sidebar-datasets-name"
          @click.prevent="nav(item.attributes.slug, item.attributes.name)"
        >{{ item.attributes.name }}
        </a>
        <div
          v-show="toggle === index"
          class="gobierto-data-sidebar-datasets-container-columns"
        >
          <span
            v-for="(column, i) in item.attributes.columns"
            :key="i"
            :item="i"
            class="gobierto-data-sidebar-datasets-links-columns"
          >
            {{ i }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  name: "Sidebar",
  props: {
    allDatasets: {
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
