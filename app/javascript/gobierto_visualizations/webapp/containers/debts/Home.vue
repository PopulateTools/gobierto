<template>
  <div>
    <div class="pure-g gutters m_b_4">
      <p>Debts</p>
    </div>
    <div class="pure-g gutters m_b_4">
      <div class="pure-u-1 pure-u-md-12-24">
        <Table :data="creditorData" />
      </div>
      <div class="pure-u-1 pure-u-md-12-24">
        <div
          ref="treemap-creditor"
          style="height: 400px"
        />
      </div>
    </div>
    <div class="pure-g gutters m_b_4">
      <div class="pure-u-1 pure-u-md-12-24">
        <Table :data="debtsData" />
      </div>
      <div class="pure-u-1 pure-u-md-12-24">
        <div
          ref="treemap-debts"
          style="height: 400px"
        />
      </div>
    </div>
  </div>
</template>
<script>
import { EventBus } from "../../lib/mixins/event_bus";
import { TreeMap } from "gobierto-vizzs";
import Table from './Table.vue';

export default {
  name: 'Home',
  components: {
    Table
  },
  data() {
    return {
      debtsData: this.$root.$data.debtsData,
      creditorData: this.$root.$data.debtsData1,
      evolutionDebtData: this.$root.$data.debtsData2,
      labelCategories: I18n.t('gobierto_visualizations.visualizations.contracts.categories') || "",
    }
  },
  mounted() {
    EventBus.$emit("mounted");
    this.initGobiertoVizzs()
  },
  methods: {
    initGobiertoVizzs() {
      const treemapCreditor = this.$refs["treemap-creditor"]
      const treemapDebts = this.$refs["treemap-debts"]
      if (treemapCreditor && treemapCreditor.offsetParent !== null) {
        this.treemapCreditor = new TreeMap(treemapCreditor, this.creditorData, {
          rootTitle: this.labelCategories,
          id: "title",
          group: ["entitat"],
          value: "endeutament"
        })
      }
      if (treemapDebts && treemapDebts.offsetParent !== null) {
        this.treemapDebts = new TreeMap(treemapDebts, this.debtsData, {
          rootTitle: this.labelCategories,
          id: "title",
          group: ["entitat"],
          value: "endeutament"
        })
      }
      this.isGobiertoVizzsLoaded = true
    }
  }
}

</script>
