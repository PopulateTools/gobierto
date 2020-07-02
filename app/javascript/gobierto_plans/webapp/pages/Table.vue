<template>
  <div class="planification-content">
    <table>
      <th>{{ uid | translate }}</th>
      <th>{{ labelProgress }}</th>
      <th><NumberLabel :level="lastLevel" /></th>
      <tr
        v-for="{ key, name, slug, progress, length } in groups"
        :key="key"
      >
        <td>
          <router-link :to="{ name: 'term', params: { ...params, term: slug } }">
            {{ name }}
          </router-link>
        </td>
        <td>{{ progress | percent }}</td>
        <td>{{ length }}</td>
      </tr>
    </table>
  </div>
</template>

<script>
import { PlansStore } from "../lib/store";
import { groupBy } from "../lib/helpers";
import { translate, percent } from "lib/shared";
import NumberLabel from "../components/NumberLabel";

export default {
  name: "Table",
  filters: {
    translate,
    percent
  },
  components: {
    NumberLabel
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
      isLoading: false,
      lastLevel: 0,
      labelProgress: I18n.t("gobierto_plans.plan_types.show.progress") || '',
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
