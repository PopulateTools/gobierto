<template>
  <tr>
    <td>
      <span class="visualizations-contracts-show__text">{{ label }}</span>
    </td>
    <td>
      <span class="visualizations-contracts-show__text"><b>{{ value }} %</b></span>
    </td>
  </tr>
</template>
<script>

export default {
  name: 'ContractsShowTableFooterLabelTr',
  props: {
    label: {
      type: String,
      default: ''
    },
    value: {
      type: String,
      default: ''
    }
  }
}
</script>
