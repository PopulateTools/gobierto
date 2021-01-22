<template>
  <div class="planification-content">
    <SectionZero :json="json" />
  </div>
</template>

<script>
import SectionZero from "../components/SectionZero";

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
