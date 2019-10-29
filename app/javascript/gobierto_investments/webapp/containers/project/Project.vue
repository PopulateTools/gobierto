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
import { GobiertoInvestmentsSharedMixin, baseUrl, configUrl } from "../../mixins/common.js";

export default {
  name: "Project",
  components: {
    Aside,
    Main
  },
  mixins: [GobiertoInvestmentsSharedMixin],
  data() {
    return {
      dictionary: [],
      phases: [],
      project: null
    };
  },
  beforeRouteEnter(to, from, next) {
    const { item } = to.params;

    if (!item) {
      // If there's no item (project) it must request it
      axios.all([axios.get(`${baseUrl}/${to.params.id}?locale=${I18n.locale}`), axios.get(`${baseUrl}/meta?stats=true&locale=${I18n.locale}`), axios.get(`${configUrl}?locale=${I18n.locale}`)]).then(responses =>
        next(vm => {
          const [
            {
              data: { data: item }
            },
            {
              data: { data: attributesDictionary, meta: filtersFromConfiguration }
            },
            { data: siteConfiguration = {} }
          ] = responses;

          vm.configuration = siteConfiguration;
          vm.dictionary = attributesDictionary;
          vm.project = vm.setItem(item);

          // Update $router
          to.params.item = vm.project;

          if (filtersFromConfiguration) {
            vm.phases = vm.getPhases(filtersFromConfiguration);
          }
        })
      );
    } else {
      next();
    }
  },
  created() {
    this.labelBack = I18n.t("gobierto_investments.projects.back");
    this.labelDetailTitle = I18n.t("gobierto_investments.projects.detail_title");

    const { item } = this.$route.params;

    if (item) {
      this.project = item;
      this.phases = item.phasesDictionary;
    }
  },
  methods: {
    navBack() {
      this.$router.push({ name: "home" });
    }
  }
};
</script>
