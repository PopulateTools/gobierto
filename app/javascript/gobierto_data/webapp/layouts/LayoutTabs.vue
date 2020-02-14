<template>
  <div>
    <div class="pure-g gutters m_b_1">
      <div class="pure-u-1 pure-u-lg-4-4">
        <Nav
          :active-tab="activeTabIndex"
          @active-tab="activeTabIndex = $event"
        />
      </div>
      <Sidebar
        :active-tab="activeTabSidebar"
        :all-datasets="allDatasets"
        :filters="filters"
        @active-tab="activeTabSidebar = $event"
      />
    </div>
  </div>
</template>
<script>
import Sidebar from "./../components/Sidebar.vue";
import Nav from "./../components/Nav.vue";
export default {
  name: "LayoutTabs",
  components: {
    Sidebar,
    Nav
  },
  props: {
    filters: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      activeTabIndex: 0,
      activeTabSidebar: 0,
      allDatasets: []
    }
  },
  mounted() {
    console.log(this.filters)
  }
}

</script>
