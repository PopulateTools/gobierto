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
      // TODO: mover el locale
      labelLoading: I18n.t("gobierto_investments.projects.loading") || ""
    };
  },
  async created() {
    const {
      data: {
        // meta,
        configuration_data: options,
        categories_vocabulary: categories
      }
    } = await this.getPlan(0);

    const { depth, summary, json } = this.setCategories(categories);

    this.json = json;
    this.summary = summary;
    options.json_depth = depth;

    this.options = options;
    PlansStore.setLevelKeys(options);

    // set this flag at the end, once every calc has been done
    this.isFetchingData = false;
  },
  methods: {
    setCategories(data) {
      const agg = groupBy(data, "level");
      const keys = Object.keys(agg);
      const summary = keys.map(a => ({ key: +a, length: agg[a].length }));

// TODO: añadir rootid, porcentajes y demás
      const fn = (data, j) => [
        ...data.filter(d => d.level < j),
        ...data.reduce((acc, item) => {
          if (item.level === j) {
            acc.push({
              ...item,
              children: data.filter(e => item.id === e.term_id)
            });
          }
          return acc;
        }, [])
      ];

      let dataParsed = data
      for (let index = keys.length; index--;) {
        dataParsed = fn(dataParsed, index)
      }

      return {
        depth: keys.length,
        summary,
        json: dataParsed
      };
    }
  }
};
</script>
