<template>
  <div>
    <table class="gobierto-visualizations-table-ods">
      <tbody>
        <tr
          v-for="(item, index) in data"
          :key="index"
          class="gobierto-visualizations-table-ods-tr"
        >
          <td class="gobierto-visualizations-table-ods-td">
            <div style="display: flex; align-items: center;" v-if="item.ods_code !== 0">
              <div style="width: 48px; height: 48px; margin-right: 15px; display: flex; align-items: center; justify-content: center; border-radius: 4px;">
                <img :src="odsImages[item.ods_code]" width="48" height="48" :alt="`ODS ${item.ods_code}`" />
              </div>
              <span>{{ item.ods_code }}. {{ odsCatalog[item.ods_code][`title_${locale}`] }}</span>
            </div>
            <div style="display: flex; align-items: center;" v-else>
              <div style="width: 48px; height: 48px; margin-right: 15px; display: flex; align-items: center; justify-content: center; border-radius: 4px; background-color: #000000;">
              </div>
              <span>Sin asignar</span>
            </div>
          </td>
          <td class="gobierto-visualizations-table-ods-td" style="text-align: right; vertical-align: middle;">
            {{ parseAmount(item.amount) }} <span class="percentage">({{ ((item.amount / total) * 100).toFixed(1) }}%)</span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>
import { VueFiltersMixin } from '../../../../lib/vue/filters'

export default {
  name: "TableOds",
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
    },
    total: {
      type: Number,
      default: 0
    }
  },
  methods: {
    parseAmount(value) {
      return !isNaN(value) ? this.$options.filters.money(value) : this.$options.filters.truncate(value)
    },
  }
}

</script>
