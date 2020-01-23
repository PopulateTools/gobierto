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
      <div
        v-if="activeTab === 1"
      >
        <a
          @click.prevent="nav(slugDataset)"
        >
          {{ titleDataset }}
        </a>
      </div>
    </div>
    <Categories v-if="activeTab === 0" />
    <Sets v-if="activeTab === 1" />
    <Queries v-if="activeTab === 2" />
  </div>
</template>


<script>
import axios from 'axios';
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
      labelCategories: "",
      titleDataset: '',
      slugDataset: ''
    }
  },
  created() {
    this.labelSets = I18n.t("gobierto_data.projects.sets")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelCategories = I18n.t("gobierto_data.projects.categories")

    this.urlPath = location.origin
    this.endPoint = '/api/v1/data/datasets';
    this.url = `${this.urlPath}${this.endPoint}`

    axios
      .get(this.url)
      .then(response => {
        this.rawData = response.data
        console.log("this.rawData", this.rawData);

        this.titleDataset = this.rawData.data[0].attributes.name
        this.slugDataset = this.rawData.data[0].attributes.slug

      })
      .catch(error => {
        console.log(error)

      })

  },
  methods: {
    activateTab(index) {
      this.$emit("active-tab", index);
    },
    nav(slugDataset) {
      this.$router.push({ name: "dataset", params: { id: slugDataset } });
    }
  }
};
</script>
