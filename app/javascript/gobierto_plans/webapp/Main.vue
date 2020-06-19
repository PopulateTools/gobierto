<template>
  <div>
    <Header :progress="globalProgress" />
    <ButtonFilters />
    <router-view
      v-if="json.length"
      :json="json"
      :options="options"
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
      options: {},
      globalProgress: 0
    }
  },
  async created() {
    const { data: { plan_tree, ...options } } = await this.getPlans({ format: 'json' });
    this.json = plan_tree;
    this.options = options;
  }
}
</script>