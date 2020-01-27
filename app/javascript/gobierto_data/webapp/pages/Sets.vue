<template>
  <div class="gobierto-data">
    <LayoutDataset>
      <DataSets />
    </LayoutDataset>
  </div>
</template>
<script>
import LayoutDataset from "./../layouts/LayoutDataset.vue";
import DataSets from "./DataSets.vue";

export default {
  name: "Sets",
  components: {
    LayoutDataset,
    DataSets
  },
  data() {
    return {
      activeTabIndex: 0,
      rawData: ''
    }
  },
  created() {

  }
}

</script>
