<template>
  <div class="planification-content">
    <SectionZero :json="json" />
  </div>
</template>

<script>
import SectionZero from "../components/SectionZero";

export default {
  name: "Home",
  components: {
    SectionZero
  },
  props: {
    json: {
      type: Array,
      default: () => []
    },
  }
};
</script>
