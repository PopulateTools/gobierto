<template>
  <Loading
    v-if="isFetchingData"
    :message="labelLoading"
  />
  <div v-else>
    <Header :options="options">
      <template v-for="{ key, length } in summary">
        <NumberLabel
          :key="key"
          :length="length"
          :level="key"
        />
      </template>
    </Header>

    <ButtonFilters />

    <router-view
      :json="json"
      :options="options"
    />
  </div>
</template>

<script>
import Header from "./components/Header.vue";
import NumberLabel from "./components/NumberLabel.vue";
import ButtonFilters from "./components/ButtonFilters.vue";
import { PlansFactoryMixin } from "./lib/factory";
import { groupBy } from "./lib/helpers";
import { PlansStore } from "./lib/store";
import { Loading } from "lib/vue-components";

export default {
  name: "Main",
  components: {
    Header,
    NumberLabel,
    ButtonFilters,
    Loading
  },
  mixins: [PlansFactoryMixin],
  data() {
    return {
      json: [],
      options: {},
      summary: [],
      isFetchingData: true,
      labelLoading: I18n.t("gobierto_plans.plan_types.show.loading") || ""
    };
  },
  async created() {
    const PLAN_ID = 0; // TODO: usar el oficial que vendrá de attributes dataset

    const [{ data: plan }, { data: projects }] = await Promise.all([
      this.getPlan(PLAN_ID),
      this.getProjects(PLAN_ID)
    ]);
    const {
      // meta,
      configuration_data: options,
      categories_vocabulary: categories
    } = plan;

    const { depth, summary, json, progress } = this.setJsonTree([
      ...categories,
      ...projects
    ]);

    this.json = json;
    this.summary = summary;
    options.json_depth = depth;
    options.global_progress = progress;

    this.options = options;
    PlansStore.setLevelKeys(options);

    // set this flag at the end, once every calc has been done
    this.isFetchingData = false;
  },
  methods: {
    setJsonTree(data) {
      const agg = groupBy(data, "level");
      const keys = Object.keys(agg);
      const summary = keys.map(a => ({ key: +a, length: agg[a].length }));
      const lastLevel = Number([...keys].pop());

      // TODO: recorremos desde abajo hacia arriba
      const fn = (data, j) => [
        ...data.filter(d => d.level < j),
        ...data.reduce((acc, item) => {
          if (item.level === j) {
            const children =
              item.level === lastLevel
                ? null
                : item.level === lastLevel - 1
                ? data.filter(e => item.id === e.category_id)
                : data.filter(e => item.id === e.term_id);

            const progress =
              item.level === lastLevel
                ? item.attributes.progress
                : children.length
                ? children.reduce((acc, { progress }) => acc + progress, 0) /
                  children.length
                  : 0;

            acc.push({
              ...item,
              progress,
              ...(children && { children })
            });
          }
          return acc;
        }, [])
      ];

      let dataParsed = data;
      // note the FOR-loop is inversed
      for (let index = keys.length; index--; ) {
        dataParsed = fn(dataParsed, index);
      }

      console.log(dataParsed, dataParsed.reduce((acc, { progress }) => acc + progress, 0));


      return {
        depth: keys.length,
        summary,
        json: dataParsed,
        progress:
          dataParsed.reduce((acc, { progress }) => acc + progress, 0) /
          dataParsed.length
      };
    }
  }
};
</script>
