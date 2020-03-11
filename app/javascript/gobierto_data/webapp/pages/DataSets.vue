<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <NavDatasets
      @active-tab="activeTabIndex = $event"
    />
  </div>
</template>
<script>
import axios from 'axios'
import { getUserId } from "./../../lib/helpers"
import { baseUrl } from "./../../lib/commons"
import NavDatasets from "./../components/sets/Nav.vue"

export default {
  name: "DataSets",
  components: {
    NavDatasets
  }
}
</script>
