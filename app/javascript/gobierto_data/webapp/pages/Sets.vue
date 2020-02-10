<template>
  <div class="gobierto-data">
    <div class="pure-g gutters m_b_1">
      <div class="pure-u-1 pure-u-lg-4-4">
        <Nav
          :active-tab="activeTabIndex"
          @active-tab="activeTabIndex = $event"
        />
      </div>
      <Sidebar
        :active-tab="activeTabSidebar"
        @active-tab="activeTabSidebar = $event"
      >
        <template v-slot:sidebar>
          <slot name="sidebar" />
        </template>
      </Sidebar>
      <DataSets
        :active-tab="activeTabIndex"
        :array-queries="arrayQueries"
        :array-formats="arrayFormats"
        :table-name="tableName"
        :dataset-id="datasetId"
        :title-dataset="titleDataset"
      />
    </div>
  </div>
</template>
<script>
import axios from 'axios'
import { getUserId } from "./../../lib/helpers"
import { baseUrl } from "./../../lib/commons"
import DataSets from "./DataSets.vue";
import Sidebar from "./../components/Sidebar.vue";
import Nav from "./../components/Nav.vue";

export default {
  name: "Sets",
  components: {
    Sidebar,
    Nav,
    DataSets
  },
  props: {
    activeTab: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      activeTabIndex: 0,
      route: this.$route.fullPath
    }
  }
}

</script>
