<template>
  <div>
    <Header :progress="globalProgress" />
    <ButtonFilters />
    <router-view
      v-if="json.length"
      :json="json"
      :level-keys="levelKeys"
    />
  </div>
</template>

<script>
import Header from "./components/Header.vue";
import ButtonFilters from "./components/ButtonFilters.vue";
import { PlansFactoryMixin } from "../lib/factory";

export default {
  name: "Main",
  components: {
    Header,
    ButtonFilters
  },
  mixins: [PlansFactoryMixin],
  data() {
    return {
      json: [],
      levelKeys: {},
      globalProgress: 0
    }
  },
  async created() {
    const { data: { plan_tree, level_keys } } = await this.getPlans({ format: 'json' });
    this.json = plan_tree;
    this.levelKeys = level_keys;
  }
}
</script>