<template>
  <aside class="investments-home-aside--gap">
    <div class="investments-home-aside--block">
      <Calendar></Calendar>
    </div>

    <div class="investments-home-aside--block">
      <BlockHeader title="Tipu de contratu" see-link></BlockHeader>
      <Checkbox v-for="item in items" :key="item.i" :item="item"></Checkbox>
    </div>

    <div class="investments-home-aside--block">
      <BlockHeader title="Estáu" see-link></BlockHeader>
      <Checkbox v-for="item in items" :key="item.i" :item="item"></Checkbox>
    </div>

    <div class="investments-home-aside--block">
      <BlockHeader title="Cantidá"></BlockHeader>
      <RangeBars :bars="6"></RangeBars>
    </div>
  </aside>
</template>

<script>
import Calendar from "../../components/Calendar.vue";
import BlockHeader from "../../components/BlockHeader.vue";
import Checkbox from "../../components/Checkbox.vue";
import RangeBars from "../../components/RangeBars.vue";

export default {
  name: "Aside",
  components: {
    Calendar,
    BlockHeader,
    Checkbox,
    RangeBars
  },
  data() {
    return {
      items: [{ i: 0, title: "a" }, { i: 1, title: "b" }, { i: 2, title: "c" }]
    };
  }
};
</script>

