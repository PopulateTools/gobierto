<template>
  <div class="planification-content">
    <router-view
      :uid="uid | translate"
      :groups="groups"
      :options="options"
    />
  </div>
</template>

<script>
import { PlansStore } from "../lib/store";
import { groupBy } from "../lib/helpers";
import { translate } from "lib/shared";

export default {
  name: "Groups",
  filters: {
    translate
  },
  props: {
    json: {
      type: Array,
      default: () => []
    },
    options: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      uid: null,
      groups: [],
    };
  },
  computed: {
    params() {
      return this.$route.params
    }
  },
  watch: {
    $route(
      {
        params: { id: newId }
      },
      {
        params: { id: oldId }
      }
    ) {
      if (newId !== oldId) {
        this.setGroups(newId);
      }
    }
  },
  created() {
    const { id } = this.$route.params;
    this.setGroups(id);

    const { last_level } = this.options;
    this.lastLevel = last_level
  },
  methods: {
    setGroups(id) {
      const { projects, meta } = PlansStore.state;
      const {
        attributes: { name_translations, vocabulary_terms }
      } = meta.find(({ attributes: { uid } = {} }) => uid === id);

      this.uid = name_translations;

      // get the projects with the differentiate attribute informed, and move it to the first level for easier aggrupation
      const projectsWithUid = projects.reduce((acc, item) => {
        const { [id]: uid } = item.attributes;
        if (uid && uid.length) {
          acc.push({ ...item, uid });
        }
        return acc;
      }, []);

      // group by the project by that uid recently created
      const groupedProjects = groupBy(projectsWithUid, "uid");

      this.groups = Object.keys(groupedProjects).map(key => {
        // properties of the key
        const {
          attributes: { name, slug }
        } = vocabulary_terms.find(({ id }) => id === key) || {};
        // items by key
        const length = groupedProjects[key].length;
        // sum all project's progresses
        const progress = length
          ? groupedProjects[key].reduce(
              (acc, { attributes: { progress } = {} }) => acc + progress,
              0
            ) / length
          : 0;

        return { key, name, slug, length, progress };
      });
    }
  }
};
</script>
