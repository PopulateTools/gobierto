<template>
  <div>
    <ButtonFilters :options="options" />

    <router-view
      :json="json"
      :options="options"
    />
  </div>
</template>

<script>
import ButtonFilters from '../components/ButtonFilters.vue';

export default {
  name: "PlanTab",
  components: {
    ButtonFilters
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
};
</script>
