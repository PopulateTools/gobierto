<template>
  <div class="investments">
    <div class="pure-g gutters">
      <div class="pure-u-1 pure-u-lg-1-4">
        <h4 class="investments-project--heading">
          <span @click="navBack"><i class="fas fa-arrow-left" /> {{ labelBack }}</span>
          <span>{{ labelDetailTitle }}</span>
        </h4>
      </div>
      <div class="pure-u-1 pure-u-lg-3-4" />
    </div>

    <div class="pure-g gutters">
      <div class="pure-u-1 pure-u-lg-1-4">
        <Aside
          v-if="project"
          :phases="phases"
          :project="project"
        />
      </div>
      <div class="pure-u-1 pure-u-lg-3-4">
        <Main
          v-if="project"
          :project="project"
        />
      </div>
    </div>
  </div>
</template>

<script>
import Aside from "./Aside.vue";
import Main from "./Main.vue";
import axios from "axios";
import { CommonsMixin } from "../../mixins/common.js";

export default {
  name: "Project",
  components: {
    Aside,
    Main
  },
  mixins: [CommonsMixin],
  data() {
    return {
      dictionary: [],
      phases: [],
      project: null
    };
  },
  created() {
    this.labelBack = I18n.t("gobierto_investments.projects.back");
    this.labelDetailTitle = I18n.t("gobierto_investments.projects.detail_title");

    const { item } = this.$route.params;

    if (item) {
      this.project = item;
      this.phases = item.phasesDictionary;
    } else {
      axios.all([axios.get(`${this.$baseUrl}/${this.$route.params.id}`), axios.get(`${this.$baseUrl}/meta?stats=true`)]).then(responses => {
        const [
          {
            data: { data: item }
          },
          {
            data: { data: attributesDictionary, meta: filtersFromConfiguration }
          }
        ] = responses;

        this.dictionary = attributesDictionary;
        this.project = this.setItem(item);

        if (filtersFromConfiguration) {
          this.phases = this.getPhases(filtersFromConfiguration)
        }
      });
    }
  },
  methods: {
    navBack() {
      this.$router.push({ name: "home" });
    }
  }
};
</script>
