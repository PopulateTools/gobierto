<template>
  <div class="planification-content">
    <section class="level_0">
      <template v-for="(model, index) in json">
        <NodeRoot
          :key="model.id"
          :classes="[ `cat_${(index % json.length) + 1}` ]"
          :model="model"
          @open-menu-mobile="openMenu = !openMenu"
        />
      </template>
    </section>
  </div>
</template>

<script>
import NodeRoot from "../components/NodeRoot";

export default {
  name: "Home",
  components: {
    NodeRoot
  },
  props: {
    json: {
      type: Array,
      default: () => []
    },
  },
  data() {
    return {
      openMenu: false
    };
  }
};
</script>
