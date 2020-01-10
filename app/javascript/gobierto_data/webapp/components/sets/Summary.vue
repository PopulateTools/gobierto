<template>
  <div class="pure-g">
    <Info />
    <Resources />
    <Queries />
  </div>
</template>

<script>
import Resources from "./../commons/Resources.vue";
import Info from "./../commons/Info.vue";
import Queries from "./../commons/Queries.vue";

export default {
  name: "Summary",
  components: {
    Resources,
    Queries,
    Info
  }
}

</script>
