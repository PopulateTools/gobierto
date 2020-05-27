<template>
  <router-link
    :to="{ name: routingMember, params: {id: item.id } }"
    tag="tr"
    class="dashboards-home-main--tr"
  >
    <td
      v-for="{ field, format, cssClass } in columns"
      class="dashboards-home-main--td"
      :class="cssClass"
    >
      <div>{{ formattedItem[field] }}</div>
    </td>
  </router-link>
</template>

<script>
import { money, truncate } from 'lib/shared'

export default {
  name: "TableRow",
  data(){
    return {
      formattedItem: {}
    }
  },
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
    }
  },
  created(){
    this.initFormattedItem();
  },
  methods: {
    initFormattedItem(){
      this.columns.forEach(({format, field}) => {
        if (format === 'currency') {
          this.formattedItem[field] = money(this.item[field]);
        } else if(format == 'truncated'){
          this.formattedItem[field] = truncate(this.item[field], {length: 60});
        } else {
          this.formattedItem[field] = this.item[field];
        }
      });
    }
  }
};
</script>
