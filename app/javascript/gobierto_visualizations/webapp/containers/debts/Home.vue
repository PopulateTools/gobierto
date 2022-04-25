<template>
  <div>
    <div class="pure-g gutters m_b_4">
      <p>Debts</p>
    </div>
  </div>
</template>
<script>

import { EventBus } from "../../lib/mixins/event_bus";

export default {
  name: 'Home',
  data() {
    return {
      contractsData: this.$root.$data.costData,
    }
  },
  mounted() {
    EventBus.$emit("mounted");
  },
}
</script>
