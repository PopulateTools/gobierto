<template>
  <div class="column">
    <h4 class="investments-project--heading">Detalle de proyecto</h4>
    <div class="pure-g">
      <div class="pure-u-1 pure-u-lg-1-4">
        <Aside></Aside>
      </div>
      <div class="pure-u-1 pure-u-lg-3-4">
        <Main></Main>
      </div>
    </div>
  </div>
</template>

<script>
import Aside from "./Aside.vue";
import Main from "./Main.vue";

export default {
  name: "Project",
  components: {
    Aside,
    Main
  }
};
</script>