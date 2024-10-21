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
        <ProjectAside
          v-if="project"
          :phases="phases"
          :project="project"
        />
      </div>
      <div class="pure-u-1 pure-u-lg-3-4">
        <ProjectMain
          v-if="project"
          :project="project"
        />
      </div>
    </div>
  </div>
</template>

<script>
import ProjectAside from './Aside.vue';
import ProjectMain from './Main.vue';
import { CommonsMixin, baseUrl } from '../../mixins/common.js';

export default {
  name: "ProjectProject",
  components: {
    ProjectAside,
    ProjectMain
  },
  mixins: [CommonsMixin],
  async beforeRouteEnter(to, from, next) {
    const { item } = to.params;

    if (!item) {
      // If there's no item (project) it must request it
      const [
        { data: item },
        { data: metadata, meta: stats }
      ] = await Promise.all([
        fetch(`${baseUrl}/${to.params.id}`).then(r => r.json()),
        fetch(`${baseUrl}/meta?stats=true`).then(r => r.json()),
      ]);

      next(async vm => {
        let project = vm.setItem(item, metadata);

        // Update $router
        to.params.item = project;

        if (stats) {
          vm.phases = vm.getPhases(stats, metadata);
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
