<template>
  <div class="gobierto-data">
    <LayoutDataset>
      <DataSets  />
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
      route: this.$route.fullPath
    }
  },
  beforeRouteEnter (to, from, next) {
    if (from.path !== "/datos") {
      next(vm => {
          vm.sendActiveTab(to.path);
          next();
      })
    } else {
      next()
    }
  },
  methods: {
    sendActiveTab(to) {
      if (to === this.route) {
        console.info('son iguales')
      } else {
        this.$root.$emit('activeTabIndex', 1)
      }
    }
  }
}

</script>
