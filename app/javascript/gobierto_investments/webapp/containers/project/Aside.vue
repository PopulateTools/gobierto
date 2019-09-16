<template>
  <aside class="investments-project-aside--gap">
    <div class="investments-project-aside--block">
      <h6 class="investments-project-aside--block-head">Estado</h6>

      <Steps :steps="items"></Steps>

      <a href class="investments-project-aside--link">ver detalle de evolución</a>
    </div>
  </aside>
</template>

<script>
import Steps from "../../components/Steps.vue";

export default {
  name: "ProjectAside",
  components: {
    Steps
  },
  data() {
    return {
      items: [{ i: 0, title: "a" }, { i: 1, title: "b" }, { i: 2, title: "c" }]
    };
  }
};
</script>

