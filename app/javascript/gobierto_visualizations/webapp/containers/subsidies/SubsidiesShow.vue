<template>
  <div>
    <h1>{{ call }}</h1>

    <div class="pure-g p_2 bg-gray">
      <div class="pure-u-1 pure-u-lg-1-2">
        <label class="soft">{{ labelBeneficiary }}</label>
        <div class="">
          <strong class="d_block">{{ beneficiary }}</strong>
        </div>
      </div>

      <div class="pure-u-1 pure-u-lg-1-2">
        <table>
          <tr>
            <th class="left">
              {{ labelAmount }}
            </th>
            <td>{{ amount | money }}</td>
          </tr>
          <tr>
            <th class="left">
              {{ labelGrantDate }}
            </th>
            <td>{{ grant_date }}</td>
          </tr>
        </table>
      </div>
    </div>
  </div>
</template>

<script>

import { VueFiltersMixin } from '../../../../lib/vue/filters'

export default {
  name: 'SubsidiesShow',
  mixins: [VueFiltersMixin],
  data() {
    return {
      subsidiesData: this.$root.$data.subsidiesData,
      call: '',
      beneficiary: '',
      labelBeneficiary: I18n.t('gobierto_visualizations.visualizations.subsidies.beneficiary'),
      labelAmount: I18n.t('gobierto_visualizations.visualizations.subsidies.amount'),
      labelGrantDate: I18n.t('gobierto_visualizations.visualizations.subsidies.date'),
    }
  },
  created() {
    const itemId = this.$route.params.id;
    const subsidy = this.subsidiesData.find(({ id }) => id === itemId ) || {};

    if (subsidy) {
      const {
        call,
        beneficiary,
        amount,
        grant_date
      } = subsidy

      this.call = call
      this.beneficiary = beneficiary
      this.amount = amount
      this.grant_date = grant_date
    }
  }
}
</script>
