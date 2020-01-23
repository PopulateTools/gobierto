<template>
  <div class="gobierto-data">
    <div class="pure-g gutters m_b_1">
      <div class="pure-u-1 pure-u-lg-4-4">
        <Nav
          :active-tab="activeTabIndex"
          @active-tab="activeTabIndex = $event"
        />
        <LayoutTabs>
          <template v-slot:sidebar />
        </LayoutTabs>
      </div>
    </div>
  </div>
</template>

<script>

const HTMLString = document.getElementsByTagName('body')[0].innerHTML;
var myRegexp = /token:(.*)/g;
var match = HTMLString.match(myRegexp);
const tokenString = match[1]
const cleanToken = tokenString.replace(/token: "/g, '').replace(/"/g, '');


import Nav from "./../components/Nav.vue";
import LayoutTabs from "./../layouts/LayoutTabs.vue";

export default {
  name: "Home",
  components: {
    Nav,
    LayoutTabs
  },
  data() {
    return {
      activeTabIndex: 0
    };
  },
  methods: {
  }
}
</script>
