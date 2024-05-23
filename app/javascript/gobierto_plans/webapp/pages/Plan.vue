<template>
  <div class="planification-content">
    <SectionZero :json="json" />
  </div>
</template>

<script>
import SectionZero from '../components/SectionZero.vue';

export default {
  name: "Plan",
  components: {
    SectionZero
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
  }
};
</script>
