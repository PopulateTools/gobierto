<template>
  <div class="gobierto-data">
    <LayoutTabs>
      <Categories />
    </LayoutTabs>
  </div>
</template>

<script>
import LayoutTabs from "./../layouts/LayoutTabs.vue";
import Categories from "./Categories.vue";

export default {
  name: "Home",
  components: {
    LayoutTabs,
    Categories
  },
  data() {
    return {
      activeTabIndex: 0
    }
  }
}
</script>
