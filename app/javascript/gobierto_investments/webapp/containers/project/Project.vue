<template>
  <div class="investments">
    <div class="pure-g gutters">
      <div class="pure-u-1 pure-u-lg-1-4">
        <h4 class="investments-project--heading">
          <span
            @click="navBack"
          ><i class="fas fa-arrow-left" /> {{ labelBack }}</span>
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
import Aside from './Aside.vue';
import Main from './Main.vue';
import axios from 'axios';
import { CommonsMixin, baseUrl } from '../../mixins/common.js';
import { Middleware } from '../../../../lib/shared';

export default {
  name: "Project",
  components: {
    Aside,
    Main
  },
  mixins: [CommonsMixin],
  async beforeRouteEnter(to, from, next) {
    const { item } = to.params;

    if (!item) {
      // If there's no item (project) it must request it
      const [
        {
          data: { data: item }
        },
        {
          data: { data: attributesDictionary, meta: filtersFromConfiguration }
        }
      ] = await axios.all([
        axios.get(`${baseUrl}/${to.params.id}`),
        axios.get(`${baseUrl}/meta?stats=true`)
      ]);

      next(async vm => {
        vm.middleware = new Middleware({
          dictionary: attributesDictionary
        });

        let project = vm.setItem(item);

        // Update $router
        to.params.item = project;

        if (filtersFromConfiguration) {
          vm.phases = vm.getPhases(filtersFromConfiguration);
        }

        vm.project = project
      });
    } else {
      next();
    }
  },
  data() {
    return {
      dictionary: [],
      phases: [],
      project: null
    };
  },
  created() {
    this.labelBack = I18n.t("gobierto_investments.projects.back");
    this.labelDetailTitle = I18n.t(
      "gobierto_investments.projects.detail_title"
    );

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
