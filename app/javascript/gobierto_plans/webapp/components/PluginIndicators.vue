<template>
  <div
    v-if="config && data && data.length"
    class="tablerow"
  >
    <div class="tablerow__title">
      {{ title | translate }}
    </div>
    <div class="tablerow__data">
      <template v-for="item in data">
        <div
          :key="item.id"
          class="tablerow__item"
        >
          <div class="tablerow__item-title">
            {{ item.name_translations | translate }}
          </div>
          <div class="tablerow__item-amount">
            {{ item.last_value }}
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script>
import { VueFiltersMixin } from "lib/shared";

export default {
  name: "Indicators",
  mixins: [VueFiltersMixin],
  props: {
    config: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      title: "",
      data: []
    };
  },
  created() {
    this.title = this.config.title_translations;
    this.data = this.config.data;
  }
};
</script>

<style lang="sass" scoped>
.tablerow {
  padding: .5em 0;

  &__title {
    font-size: 14px;
    text-transform: uppercase;
    font-weight: 700;
    margin-bottom: 25px;
  }

  &__data {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    grid-gap: 20px 20px;

    @media screen and (min-width: 768px) {
      grid-gap: 40px 40px;
    }
  }

  &__item {
    background-color: rgba(#D8D8D8, 0.2);
    padding: 0.5em 1em;

    &-title {
      font-size: 14px;
    }

    &-amount {
      font-size: 36px;
      font-weight: 400;
      line-height: 43px;
    }
  }
}
</style>