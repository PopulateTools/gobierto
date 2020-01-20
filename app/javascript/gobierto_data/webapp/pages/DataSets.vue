<template>
  <div>
    <LayoutTabs>
      <template v-slot:sidebar />
    </LayoutTabs>
  </div>
</template>
<script>
import LayoutTabs from "./../layouts/LayoutTabs.vue";

export default {
  name: "Datasets",
  components: {
    LayoutTabs
  }
}

</script>
