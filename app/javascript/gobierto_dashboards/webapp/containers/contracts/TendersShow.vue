<template>
  <div>
    <h1>{{ title }}</h1>

    <p v-if="description">
      {{ description }}
    </p>

    <div class="pure-g p_2 bg-gray">
      <div class="pure-u-1 pure-u-lg-1-2">
      </div>

      <div class="pure-u-1 pure-u-lg-1-2">
        <table>
          <tr>
            <th class="left">{{ labelTenderAmount }}</th>
            <td>{{ initial_amount_no_taxes | money }}</td>
          </tr>
          <tr>
            <th class="left">{{ labelStatus }}</th>
            <td>{{ status }}</td>
          </tr>
          <tr>
            <th class="left">{{ labelProcessType }}</th>
            <td>{{ process_type }}</td>
          </tr>
          <tr>
            <th class="left">
              <a :href="permalink" target='blank'>{{ labelPermalink }}</a>
            </th>
          </tr>
        </table>
      </div>
    </div>

  </div>
</template>

<script>
import { VueFiltersMixin } from "lib/shared"

export default {
  name: 'TendersShow',
  mixins: [VueFiltersMixin],
  data() {
    return {
      tendersData: this.$root.$data.tendersData,
      title : '',
      description : '',
      initial_amount_no_taxes : '',
      status : '',
      process_type : '',
      permalink : '',
      labelTenderAmount: I18n.t('gobierto_dashboards.dashboards.contracts.tender_amount'),
      labelContractAmount: I18n.t('gobierto_dashboards.dashboards.contracts.contract_amount'),
      labelStatus: I18n.t('gobierto_dashboards.dashboards.contracts.status'),
      labelProcessType: I18n.t('gobierto_dashboards.dashboards.contracts.process_type'),
      labelPermalink: I18n.t('gobierto_dashboards.dashboards.contracts.permalink')
    }
  },
  created() {
    const itemId = this.$route.params.id;

    const tender = this.tendersData.find((data) => {
      return data.id === itemId
    });

    if (tender) {
      const {
        title,
        description,
        initial_amount_no_taxes,
        status,
        process_type,
        permalink
      } = tender

      this.title = title
      this.description = description
      this.initial_amount_no_taxes = initial_amount_no_taxes
      this.status = status
      this.process_type = process_type
      this.permalink = permalink
    }

  }
}
</script>
