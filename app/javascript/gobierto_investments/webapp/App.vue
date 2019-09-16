<template>
  <keep-alive>
    <component v-bind:is="currentTabComponent"></component>
  </keep-alive>
</template>

<script>
import Vue from "vue";
import Home from "./containers/home/Home.vue";
import Project from "./containers/project/Project.vue";

export default {
  name: "Investments",
  data() {
    return {
      currentTabComponent: null
    };
  },
  created() {
    // TODO
    this.currentTabComponent = Home;
  }
};
</script>