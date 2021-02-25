<template>
  <main class="investments-home-main">
    <transition
      name="fade"
      mode="out-in"
    >
      <keep-alive>
        <component
          :is="currentTabComponent"
          :items="items"
        />
      </keep-alive>
    </transition>
  </main>
</template>

<script>
// define the components as dynamic
const COMPONENTS = [
  () => import("../../components/Map.vue"),
  () => import("../../components/Gallery.vue"),
  () => import("../../components/List.vue")
];

export default {
  name: "HomeMain",
  props: {
    activeTab: {
      type: Number,
      default: 0
    },
    items: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      tabs: COMPONENTS,
      currentTabComponent: null
    };
  },
  watch: {
    activeTab(tab) {
      this.currentTabComponent = this.tabs[tab];
    }
  },
  created() {
    this.currentTabComponent = this.tabs[this.activeTab];
  }
};
</script>