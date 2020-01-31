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
        @active-tab="activeTabSidebar = $event"
      >
        <template v-slot:sidebar>
          <slot name="sidebar" />
        </template>
      </Sidebar>
      <slot />
    </div>
  </div>
</template>
<script>
import axios from 'axios';
import Sidebar from "./../components/Sidebar.vue";
import Nav from "./../components/Nav.vue";

export default {
  components: {
    Sidebar,
    Nav
  },
  data() {
    return {
      activeTabIndex: 0,
      activeTabSidebar: 0,
      allDatasets: []
    }
  },
  created(){
    this.urlPath = location.origin
    this.endPoint = '/api/v1/data/datasets';
    this.url = `${this.urlPath}${this.endPoint}`

    axios
      .get(this.url)
      .then(response => {
        this.rawData = response.data

        this.allDatasets = this.rawData.data

      })
      .catch(error => {
        console.error(error)
      })
  }
}

</script>
