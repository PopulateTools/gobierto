<template>
  <div class="pure-u-1 pure-u-lg-1-1 visualizations-contracts-show__body__group">
    <span class="visualizations-contracts-show__text__header">{{ label }}</span>
    <span class="visualizations-contracts-show__text">{{ value }}</span>
  </div>
</template>

<script>

export default {
  name: 'ContractsShowLabelGroup',
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
