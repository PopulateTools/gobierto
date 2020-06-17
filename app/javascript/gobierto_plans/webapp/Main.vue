<template>
  <div>
    <Header :progress="globalProgress" />
    <ButtonFilters />
    <div class="planification-content">
      <router-view :json="json" />
    </div>
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
      globalProgress: 0
    }
  },
  async created() {
    const { data: { plan_tree } } = await this.getPlans({ format: 'json' });
    this.json = plan_tree;
  }
}
</script>