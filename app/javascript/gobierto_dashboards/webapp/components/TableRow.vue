<template>
  <router-link
    :to="{ name: routingMember, params: {id: routingId } }"
    tag="tr"
    class="dashboards-home-main--tr"
  >
    <td
      v-for="{ field, format, cssClass } in columns"
      :key="field"
      class="dashboards-home-main--td"
      :class="cssClass"
    >
      <span class="dashboards-home-main--td-text">{{ formattedItem[field] }}</span>
    </td>
  </router-link>
</template>

<script>
import { money, truncate } from 'lib/shared'

export default {
  name: "TableRow",
  props: {
    item: {
      type: Object,
      default: () => {}
    },
    columns: {
      type: Array,
      default: () => []
    },
    routingMember: {
      type: String,
      default: ''
    },
    routingAttribute: {
      type: String,
      default: 'id'
    }
  },
  data(){
    return {
      formattedItem: {}
    }
  },
  created(){
    this.initFormattedItem();
    this.routingId = this.item[this.routingAttribute];
  },
  methods: {
    initFormattedItem(){
      this.columns.forEach(({ format, field }) => {
        if (format === 'currency') {
          this.formattedItem[field] = money(this.item[field]);
        } else if (format == 'truncated'){
          this.formattedItem[field] = truncate(this.item[field], { length: 60 });
        } else {
          this.formattedItem[field] = this.item[field];
        }
      });
    }
  }
};
</script>
