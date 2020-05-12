<template>
  <tr class="dashboards-home-main--tr" @click="navigateTo(item)" >
    <td
      v-for="{ field } in columns"
      class="dashboards-home-main--td"
    >
      <div>{{ formattedItem[field] }}</div>
    </td>
  </tr>
</template>

<script>
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
    navigateTo(item) {
      this.$router.push({ name: this.routingMember, params: { id: item.id, item } });
    },
    initFormattedItem(){
      const _self = this;

      _self.columns.forEach(function(column){
        if (column.format === 'currency') {
          _self.formattedItem[column.field] = parseFloat(_self.item[column.field]).toLocaleString(I18n.locale, {
            style: 'currency',
            currency: 'EUR'
          });
        } else {
          _self.formattedItem[column.field] = _self.item[column.field]
        };
      });
    }
  }
};
</script>
