<template>
  <div>
    <div class="pure-g m_b_1">
      <div class="pure-u-1 pure-u-lg-1-4" />
      <div class="pure-u-1 pure-u-lg-3-4">
        <Nav @active-tab="activeTabIndex = $event" />
      </div>
    </div>

    <div class="pure-g m_b_4">
      <div class="pure-u-1 pure-u-lg-1-4">
        <Aside />
      </div>
      <div class="pure-u-1 pure-u-lg-3-4">
        <Main :active-tab="activeTabIndex" :items="items" />
      </div>
    </div>
  </div>
</template>

<script>
import Aside from "./Aside.vue";
import Main from "./Main.vue";
import Nav from "./Nav.vue";
import axios from "axios";

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
    axios.get(this.$endpoint).then(response => {
      if (response.data) {
        const { data = [] } = response.data;
        this.items = data;
        // this.items = parse(data);
      }
    });
  },
  methods: {
    parse(data) {
      return data.map(d => ({
        id: parseInt(d.id)
        // title
      }));
    }
  }
};
</script>