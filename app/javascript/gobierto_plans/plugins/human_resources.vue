<template>
  <div class="tablerow" v-if="config">
    <div class="tablerow__title">{{ title | translate }}</div>
    <div class="tablerow__data">
      <div class="tablerow__item">
        <div>Inicial</div>
        <div class="tablerow__amount">
          <div class="tablerow__amount--numeric">{{ budgetedAmount | money }}</div>
          <div class="tablerow__amount--percent">100%</div>
        </div>
      </div>
      <div class="tablerow__item">
        <div>Ejecutado</div>
        <div class="tablerow__amount">
          <div class="tablerow__amount--numeric">{{ executedAmount | money }}</div>
          <div class="tablerow__amount--percent">{{ executedPercent }}</div>
        </div>
      </div>
    </div>
    <div class="tablerow__extra">
      <a v-if="detail" :href="detail.link">{{ detail.text }}</a>
    </div>
  </div>
</template>

<script>
export default {
  name: "HumanResources",
  props: {
    config: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      title: '',
      detail: {},
      budgetedAmount: 0,
      executedAmount: 0,
      executedPercent: ''
    };
  },
  filters: {
    translate(value) {
      const lang = I18n.locale || "es";
      return value[lang];
    },
    money(value) {
      const lang = I18n.locale || "es";
      if (value) {
        return value.toLocaleString(lang, { style: "currency", currency: "EUR" });
      }
    }
  },
  created() {
    this.title = this.config.title_translations
    this.detail = this.config.detail
    this.budgetedAmount = this.config.budgeted_amount
    this.executedAmount = this.config.executed_amount
    this.executedPercent = this.config.executed_percentage
  }
};
</script>

<style lang="sass" scoped>
.tablerow {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
  min-height: 100px;
  padding: .5em 0;

  &__title {
    flex: 0 0 25%;
    text-transform: uppercase;
    font-weight: 700;
  }

  &__data {
    flex: 1;
  }

  &__item {
    display: flex;
    justify-content: space-between;
  }

  &__amount {
    display: flex;
    justify-content: space-between;
    flex: 0 0 50%;

    &--numeric {
      font-weight: 700;
      text-align: right;
      flex: 0 0 70%;
    }

    &--percent {
      opacity: 0.5;
    }
  }

  &__extra {
    flex: 0 0 33%;
    font-size: 12px;
    text-align: right;
  }
}
</style>
