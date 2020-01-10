<template>
  <div class="pure-g">
    <div class="pure-u-1 pure-u-lg-1-4 gobierto-data-layout-column gobierto-data-layout-sidebar">
      <nav class="gobierto-data-tabs-sidebar">
        <ul>
          <li
            :class="{ 'is-active': activeTab === 0 }"
            class="gobierto-data-tab-sidebar--tab"
            @click="activateTab(0)"
          >
            <span>{{ labelCategories }}</span>
          </li>
          <li
            :class="{ 'is-active': activeTab === 1 }"
            class="gobierto-data-tab-sidebar--tab"
            @click="activateTab(1)"
          >
            <span>{{ labelSets }}</span>
          </li>
          <li
            :class="{ 'is-active': activeTab === 2 }"
            class="gobierto-data-tab-sidebar--tab"
            @click="activateTab(2)"
          >
            <span>{{ labelQueries }}</span>
          </li>
        </ul>
      </nav>
    </div>
    <Sets v-if="activeTab === 0" />
    <Categories v-if="activeTab === 1" />
    <Queries v-if="activeTab === 2" />
  </div>
</template>


<script>
import Categories from "./../pages/Categories.vue";
import Queries from "./../pages/Queries.vue";
import Sets from "./../pages/Sets.vue";

export default {
  name: "Sidebar",
  components: {
    Sets,
    Categories,
    Queries
  },
  props: {
    activeTab: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      labelSets: "",
      labelQueries: "",
      labelCategories: ""
    }
  },
  created() {
    this.labelSets = I18n.t("gobierto_data.projects.sets")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelCategories = I18n.t("gobierto_data.projects.categories")
  },
  methods: {
    activateTab(index) {
      this.$emit("active-tab", index);
    }
  }
};
</script>
