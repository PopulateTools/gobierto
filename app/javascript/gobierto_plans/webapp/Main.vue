<template>
  <div v-if="json.length">
    <Header :options="options">
      <template v-for="[key, length] in summary">
        <NumberLabel
          :key="key"
          :keys="levelKeys"
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
import { PlansFactoryMixin } from "../lib/factory";
import { recursiveChildrenCount } from "../lib/helpers";

export default {
  name: "Main",
  components: {
    Header,
    NumberLabel,
    ButtonFilters
  },
  mixins: [PlansFactoryMixin],
  data() {
    return {
      json: [],
      options: {},
      levelKeys: {},
      summary: []
    }
  },
  async created() {
    const { data: { plan_tree, ...options } } = await this.getPlans({ format: 'json' });
    this.json = plan_tree;

    const jsonMap = recursiveChildrenCount(plan_tree)
    this.summary = Array.from(jsonMap)
    options.json_depth = jsonMap.size

    this.options = options;

    const { level_keys } = options
    this.levelKeys = level_keys
  }
}
</script>