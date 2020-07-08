<template>
  <div class="planification-content">
    <transition name="fade">
      <router-view
        :key="uid"
        :groups="groups"
        :json="json"
        :options="options"
      />
    </transition>
  </div>
</template>

<script>
import { PlansStore } from "../lib/store";
import { groupBy } from "../lib/helpers";

export default {
  name: "Groups",
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
      groups: []
    };
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
        this.uid = newId
        this.setGroups(newId);
      }
    }
  },
  created() {
    const { id } = this.$route.params;
    this.uid = id
    this.setGroups(id);
  },
  methods: {
    setGroups(id) {
      const { projects, meta } = PlansStore.state;
      const {
        attributes: { vocabulary_terms }
      } = meta.find(({ attributes: { uid } = {} }) => uid === id);

      // get the projects with the differentiate attribute informed, and move it to the first level for easier aggrupation
      const projectsWithUid = projects.reduce((acc, item) => {
        const { [id]: uid } = item.attributes;
        if (uid && uid.length) {
          // to handle multiple keys
          const uids = Array.isArray(uid) ? uid : [uid];
          for (let index = 0; index < uids.length; index++) {
            const element = uids[index];
            acc.push({ ...item, uid: element });
          }
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
        const children = groupedProjects[key] || [];
        const length = children.length;
        // sum all project's progresses
        const progress = length
          ? groupedProjects[key].reduce(
              (acc, { attributes: { progress } = {} }) => acc + progress,
              0
            ) / length
          : 0;

        return { key, name, slug, length, children, progress };
      });
    }
  }
};
</script>
