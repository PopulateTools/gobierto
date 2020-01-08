<template>
  <div class="investments">
    <div class="pure-g gutters m_b_1">
      <div class="pure-u-1 pure-u-lg-1-4" />
      <div class="pure-u-1 pure-u-lg-3-4">
        <Nav
          :active-tab="activeTabIndex"
          @active-tab="activeTabIndex = $event"
        />
      </div>
    </div>

    <div class="pure-g gutters m_b_4">
      <div class="pure-u-1 pure-u-lg-1-4">
        <Aside
          :filters="filters"
          @set-filter="filterItems"
        />
      </div>
      <div class="pure-u-1 pure-u-lg-3-4">
        <Main
          v-if="items.length"
          :active-tab="activeTabIndex"
          :items="subsetItems"
        />
      </div>
    </div>

    <article>
    </article>
  </div>
</template>

<script>
import Nav from "./Nav.vue";


export default {
  name: "Home",
  components: {
    Nav
  },
  data() {
    return {
      items: [],
      subsetItems: [],
      dictionary: [],
      filters: [],
      phases: [],
      activeTabIndex: 0,
      labelSummary: ""
    };
  },
  methods: {
  }
};
</script>
