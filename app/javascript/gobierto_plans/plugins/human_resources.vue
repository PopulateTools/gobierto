<template>
  <div
    v-if="config && (budgetedAmount || executedAmount)"
    class="tablerow"
  >
    <div class="tablerow__title">
      {{ title | translate }}
    </div>
    <div class="tablerow__data">
      <div
        v-if="budgetedAmount"
        class="tablerow__item"
      >
        <div>Inicial</div>
        <div class="tablerow__amount">
          <div class="tablerow__amount--numeric">
            {{ budgetedAmount | money }}
          </div>
          <div class="tablerow__amount--percent">
            100%
          </div>
        </div>
      </div>
      <div
        v-if="executedAmount"
        class="tablerow__item"
      >
        <div>Ejecutado</div>
        <div class="tablerow__amount">
          <div class="tablerow__amount--numeric">
            {{ executedAmount | money }}
          </div>
          <div class="tablerow__amount--percent">
            {{ executedPercent }}
          </div>
        </div>
      </div>
    </div>
    <div class="tablerow__extra">
      <a
        v-if="detail"
        :href="detail.link"
      >{{ detail.text }}</a>
    </div>
  </div>
</template>

<script>
import { VueUtilsMixin } from "lib/shared";

export default {
  name: "HumanResources",
  mixins: [VueUtilsMixin],
  props: {
    config: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      title: "",
      detail: {},
      budgetedAmount: 0,
      executedAmount: 0,
      executedPercent: ""
    };
  },
  created() {
    this.title = this.config.title_translations;
    this.detail = this.config.detail;
    this.budgetedAmount = this.config.budgeted_amount;
    this.executedAmount = this.config.executed_amount;
    this.executedPercent = this.config.executed_percentage;
  }
};
</script>

<style lang="sass" scoped>
.tablerow {
  display: flex;
  justify-content: space-between;
  flex-direction: column;
  font-size: 14px;
  min-height: 100px;
  padding: .5em 0;

  @media screen and (min-width: 768px) {
    flex-direction: row;
  }

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
