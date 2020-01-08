<template>
  <div class="gobierto-data">
    <div class="pure-g gutters m_b_1">
      <div class="pure-u-1 pure-u-lg-4-4">
        <Nav
          :active-tab="activeTabIndex"
          @active-tab="activeTabIndex = $event"
        />
      </div>
    </div>
  </div>
</template>

<script>
import Nav from "./../components/Nav.vue";


export default {
  name: "Home",
  components: {
    Nav
  },
  data() {
    return {
      activeTabIndex: 0
    };
  },
  methods: {
  }
};
</script>
