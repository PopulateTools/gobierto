<template>
  <div class="tablerow" v-if="config">
    <div class="tablerow__title">{{ title | translate }}</div>
    <div class="tablerow__data">
      <template v-for="item in data">
        <div class="tablerow__item" :key="item.id">
          <div class="tablerow__item-title">{{ item.name_translations | translate }}</div>
          <div class="tablerow__item-amount">{{ item.last_value }}</div>
        </div>
      </template>
    </div>
  </div>
</template>

<script>
export default {
  name: "Indicators",
  props: {
    config: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      title: '',
      data: []
    };
  },
  filters: {
    translate(value) {
      const lang = I18n.locale || "es";
      return value[lang];
    }
  },
    created() {
    this.title = this.config.title_translations
    this.data = this.config.data
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
    grid-gap: 40px 40px;
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