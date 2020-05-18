<template>
  <main>
    <div class="pure-g gutters m_b_4">
      <Aside></Aside>

      <div class="pure-u-1 pure-u-lg-3-4">
        <Nav
          :active-tab="activeTabIndex"
          @active-tab="setActiveTab"
        ></Nav>
        <main class="dashboards-home-main">
          <router-view></router-view>
        </main>
      </div>
    </div>
  </main>
</template>

<script>
import Nav from "./Nav.vue";
import Aside from "./Aside.vue";

import { store } from "../../mixins/store";

export default {
  name: 'Home',
  components: {
    Aside,
    Nav
  },
  data() {
    return {
      activeTabIndex: store.state.currentTab || 0,
    }
  },
  methods: {
    setActiveTab(value) {
      this.activeTabIndex = value;
      store.addCurrentTab(value);
    },
  }

}
</script>
