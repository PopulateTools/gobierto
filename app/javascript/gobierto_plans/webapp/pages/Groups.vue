<template>
  <div class="planification-content">
    <router-view
      :key="uid"
      :groups="groups"
      :json="json"
      :options="options"
    />
  </div>
</template>

<script>
import { PlansStore } from '../lib/store';
import { groupBy } from '../lib/helpers';

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
        this.uid = newId;
        this.setGroups(newId);
      }
    }
  },
  created() {
    const { id } = this.$route.params;
    this.uid = id;
    this.setGroups(id);
  },
  methods: {
    setGroups(id) {
      const { projects, meta, status } = PlansStore.state;

      // if there's no matching in meta fields, use the status
      const { attributes: { vocabulary_terms = status } = {} } = meta.find(({ attributes: { uid } = {} }) => uid === id) || {};

      // get the projects with the differentiate attribute informed, and move it to the first level for easier aggrupation
      const projectsWithUid = projects.reduce((acc, item) => {
        const { [id]: uid, status_id } = item.attributes;

        if (uid && uid.length) {
          // to handle multiple keys
          const uids = Array.isArray(uid) ? uid : [uid];
          for (let index = 0; index < uids.length; index++) {
            const element = uids[index];
            acc.push({ ...item, uid: element });
          }
        } else if (status_id) {
          // handle status as a custom field
          acc.push({ ...item, uid: status_id });
        }
        return acc;
      }, []);

      // group by the project by that uid recently created
      const groupedProjects = groupBy(projectsWithUid, "uid");

      // helper function to create the array with the required properties
      const parseProjects = (keys) => keys.map(key => {
        // properties of the key
        const {
          id,
          attributes: { name, slug, level } = {}
        } = vocabulary_terms.find(({ id }) => id === key) || {};
        // items by key
        const children = groupedProjects[key] || [];
        const length = children.length;
        // sum all project's progresses
        const progress = length
          ? children.reduce((acc, { attributes: { progress } = {} }) => acc + progress, 0) / length
          : 0;

        // nested groups ids
        const nestedGroups = vocabulary_terms.reduce(
          (acc, { id: nestId, attributes: { term_id } }) => {
            // only need those inner groups selected
            if (keys.includes(nestId) && +id === +term_id) {
              acc.push(nestId)
            }
            return acc
          }, []);

        // percent out of total
        const percentOutOfTotal = 100 * (length / projectsWithUid.length)

        return { key, name, slug, length, children, progress, level, nestedGroups, percentOutOfTotal };
      })

      this.groups = parseProjects(Object.keys(groupedProjects));
    }
  }
};
</script>
