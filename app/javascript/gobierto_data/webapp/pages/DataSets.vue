<template>
  <div>
    <NavDatasets
      :active-tab="activeTabIndex"
      @active-tab="activeTabIndex = $event"
    />
  </div>
</template>
<script>
import NavDatasets from "./../components/sets/Nav.vue";

export default {
  name: "DataSets",
  components: {
    NavDatasets
  },
  data() {
    return {
      activeTabIndex: 0
    }
  }
}

</script>
