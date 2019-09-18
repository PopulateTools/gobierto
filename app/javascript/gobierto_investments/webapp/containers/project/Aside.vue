<template>
  <aside class="investments-project-aside--gap">
    <div class="investments-project-aside--block">
      <h6 class="investments-project-aside--block-head">
        Estado
      </h6>

      <Steps :steps="items" />

      <a
        href
        class="investments-project-aside--link"
      >ver detalle de evolución</a>
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
  props: {
    items: {
      type: Array,
      default: () => []
    }
  }
};
</script>

