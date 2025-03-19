<template>
  <div>
    <table class="gobierto-visualizations-table-budgets-ods">
      <colgroup>
        <col style="width: 20%">  <!-- Code column -->
        <col style="width: 25%">  <!-- Name column -->
        <col style="width: 20%">  <!-- Amount column -->
        <col style="width: 35%">  <!-- ODS chart column (35% = slightly more than 1/3) -->
      </colgroup>
      <thead>
        <tr>
          <th>Código programa</th>
          <th>Nombre</th>
          <th>Importe</th>
          <th colspan="4" class="ods-chart-column">ODS</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(item, index) in data"
          v-if="item.ods_code !== 0"
          :key="index"
          class="gobierto-visualizations-table-budgets-ods-tr"
        >
          <td class="gobierto-visualizations-table-budgets-ods-td">
            {{ item.functional_code }}
          </td>
          <td class="gobierto-visualizations-table-budgets-ods-td">
            {{ item.name }}
          </td>
          <td class="gobierto-visualizations-table-budgets-ods-td">
            {{ parseAmount(item.amount) }}
          </td>
          <td class="gobierto-visualizations-table-budgets-ods-td ods-chart-column" colspan="4">
            <div class="ods-bar-container" @mouseover="showTooltip($event, item)" @mouseleave="hideTooltip">
              <div
                v-if="item.primary_ods && item.primary_ods_amount"
                class="ods-segment"
                :style="{
                  width: `${(item.primary_ods_amount / item.amount) * 100}%`,
                  backgroundColor: odsCatalog[item.primary_ods] ? odsCatalog[item.primary_ods].color : '#ccc'
                }"
              ></div>
              <div
                v-for="i in 4"
                v-if="item[`secondary_ods_${i}`] && item[`secondary_ods_${i}_amount`]"
                class="ods-segment"
                :style="{
                  width: `${(item[`secondary_ods_${i}_amount`] / item.amount) * 100}%`,
                  backgroundColor: odsCatalog[item[`secondary_ods_${i}`]] ? odsCatalog[item[`secondary_ods_${i}`]].color : '#ccc'
                }"
              ></div>
            </div>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Tooltip component -->
    <div v-if="tooltipVisible" class="ods-tooltip" :style="tooltipStyle" v-html="tooltipContent"></div>
  </div>
</template>

<script>
import { VueFiltersMixin } from '../../../../lib/vue/filters'

export default {
  name: "TableBudgetsOds",
  mixins: [VueFiltersMixin],
  props: {
    data: {
      type: Array,
      default: () => []
    },
    odsCatalog: {
      type: Object,
      default: () => {}
    },
    odsImages: {
      type: Object,
      default: () => {}
    },
    locale: {
      type: String,
      default: 'es'
    }
  },
  data() {
    return {
      tooltipVisible: false,
      tooltipContent: '',
      tooltipStyle: {
        top: '0px',
        left: '0px'
      }
    }
  },
  methods: {
    parseAmount(value) {
      return !isNaN(value) ? this.$options.filters.money(value) : this.$options.filters.truncate(value)
    },

    showTooltip(event, item) {
      // Prepare ODS information
      const odsInfo = [];

      // Add primary ODS to info
      if (item.primary_ods && item.primary_ods_amount) {
        const primaryPercentage = (item.primary_ods_amount / item.amount) * 100;
        odsInfo.push({
          name: this.odsCatalog[item.primary_ods]?.name || `ODS ${item.primary_ods}`,
          color: this.odsCatalog[item.primary_ods] !== undefined ? this.odsCatalog[item.primary_ods].color : '#ccc',
          code: item.primary_ods,
          amount: item.primary_ods_amount,
          percentage: primaryPercentage.toFixed(2),
          isPrimary: true
        });
      }

      // Add secondary ODS segments to info
      for (let i = 1; i <= 4; i++) {
        const odsCode = item[`secondary_ods_${i}`];
        const odsAmount = item[`secondary_ods_${i}_amount`];

        if (odsCode && odsAmount) {
          const percentage = (odsAmount / item.amount) * 100;
          odsInfo.push({
            name: this.odsCatalog[odsCode]?.name || `ODS ${odsCode}`,
            code: odsCode,
            color: this.odsCatalog[odsCode] !== undefined ? this.odsCatalog[odsCode].color : '#ccc',
            amount: odsAmount,
            percentage: percentage.toFixed(2),
            isPrimary: false
          });
        }
      }

      // Generate tooltip content
      this.tooltipContent = this.createTooltipContent(odsInfo, item.amount);

      // Calculate position (offset from mouse)
      this.tooltipStyle = {
        top: `${event.pageY - 600}px`,
        left: `${event.pageX - 100}px`
      };

      // Show tooltip
      this.tooltipVisible = true;
    },

    hideTooltip() {
      this.tooltipVisible = true;
    },

    createTooltipContent(odsInfo, totalAmount) {
      let content = '<div class="ods-tooltip-content">';
      content += '<h4>Distribución ODS</h4>';
      content += '<table class="ods-tooltip-table">';
      content += '<thead><tr><th>ODS</th><th>Importe</th><th>%</th></tr></thead>';
      content += '<tbody>';

      odsInfo.forEach(ods => {
        content += `<tr class="${ods.isPrimary ? 'primary-ods' : 'secondary-ods'}">`;
        content += `<td><span style="background-color: ${ods.color}; width: 10px; height: 10px; border-radius: 50%; display: inline-block; margin-right: 5px;"></span>${ods.name}</td>`;
        content += `<td>${this.parseAmount(ods.amount)}</td>`;
        content += `<td>${ods.percentage}%</td>`;
        content += '</tr>';
      });

      content += '</tbody>';
      content += `<tfoot><tr><td>Total</td><td colspan="2">${this.parseAmount(totalAmount)}</td></tr></tfoot>`;
      content += '</table>';
      content += '</div>';

      return content;
    }
  }
}
</script>

<style scoped>
.ods-bar-container {
  display: flex;
  width: 100%;
  height: 24px;
  border-radius: 4px;
  overflow: hidden;
  cursor: pointer;
}

.ods-segment {
  height: 100%;
}

.ods-tooltip {
  position: absolute;
  z-index: 1000;
  background-color: white;
  border: 1px solid #ccc;
  border-radius: 4px;
  padding: 10px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
  min-width: 400px;
  max-width: 500px;
  font-size: 14px;
}

.ods-tooltip-content h4 {
  margin-top: 0;
  margin-bottom: 8px;
  font-size: 14px;
  border-bottom: 1px solid #eee;
  padding-bottom: 4px;
}

.ods-tooltip-table {
  width: 100%;
  border-collapse: collapse;
}

.ods-tooltip-table th,
.ods-tooltip-table td {
  padding: 4px 8px;
  text-align: left;
  border-bottom: 1px solid #eee;
}

.ods-tooltip-table th {
  font-weight: bold;
  background-color: #f5f5f5;
}

.primary-ods {
  font-weight: bold;
}
</style>
