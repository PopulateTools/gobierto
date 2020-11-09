<template>
  <div>
    <p>Precios</p>
  </div>
</template>

<script>

import { getDataMixin } from "../lib/getData";
export default {
  name: 'PricesChart',
  mixins: [getDataMixin],
  data() {
    return {
      query: '?sql=SELECT EXTRACT(YEAR FROM start_date), final_amount, initial_amount FROM contratos GROUP by start_date, final_amount, initial_amount'
    }
  },
  async created() {
    const dataFromQuery = await this.getData(this.query)
  }
}
</script>
