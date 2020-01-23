<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <DataSets />
  </div>
</template>
<script>
import DataSets from "./DataSets.vue";

export default {
  name: "Sets",
  components: {
    DataSets
  },
  data() {
    return {
      activeTabIndex: 0
    }
  }
}

</script>
