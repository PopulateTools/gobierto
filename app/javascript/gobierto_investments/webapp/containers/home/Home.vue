<template>
  <div>
    <div class="pure-g m_b_1">
      <div class="pure-u-1 pure-u-lg-1-4"></div>
      <div class="pure-u-1 pure-u-lg-3-4">
        <Nav @active-tab="activeTabIndex = $event"></Nav>
      </div>
    </div>

    <div class="pure-g m_b_4">
      <div class="pure-u-1 pure-u-lg-1-4">
        <Aside></Aside>
      </div>
      <div class="pure-u-1 pure-u-lg-3-4">
        <Main :active-tab="activeTabIndex" :items="items"></Main>
      </div>
    </div>
  </div>
</template>

<script>
import Aside from "./Aside.vue";
import Main from "./Main.vue";
import Nav from "./Nav.vue";

export default {
  name: "Home",
  components: {
    Aside,
    Main,
    Nav
  },
  data() {
    return {
      items: [],
      activeTabIndex: 0
    };
  },
  created() {
    // fake data
    this.items = [...Array(20)].map((e, i) => ({
      id: i,
      title: Math.random()
        .toString(36)
        .substring(7),
      status: Math.random()
        .toString(36)
        .substring(7),
      import: ~~(Math.random() * 1e7)
    }));
  }
};
</script>