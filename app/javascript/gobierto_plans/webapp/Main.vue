<template>
  <div v-if="json.length">
    <Header :options="options">
      <template v-for="lvl in numberOfLevelKeys">
        <!-- TODO: calculate number of items each cat -->
        <NumberLabel
          :key="lvl"
          :keys="levelKeys"
          :length="10"
          :level="lvl - 1"
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
      levelKeys: {}
    }
  },
  computed: {
    numberOfLevelKeys() {
      return Object.keys(this.levelKeys).length
    }
  },
  async created() {
    const { data: { plan_tree, ...options } } = await this.getPlans({ format: 'json' });
    this.json = plan_tree;
    this.options = options;

    const { level_keys } = options
    this.levelKeys = level_keys
  }
}
</script>