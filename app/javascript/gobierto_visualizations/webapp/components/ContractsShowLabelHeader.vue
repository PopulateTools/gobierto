<template>
  <div class="visualizations-contracts-show__header__group">
    <i
      class="fas visualizations-contracts-show__icon"
      :class="'fa-' + icon"
    />
    <span class="visualizations-contracts-show__text">
      {{ label }}
    </span>
    <span class="visualizations-contracts-show__text visualizations-contracts-show__text__bold">
      {{ value }}
    </span>
  </div>
</template>

<script>

export default {
  name: 'ContractsShowLabelHeader',
  props: {
    label: {
      type: String,
      default: ''
    },
    value: {
      type: String,
      default: ''
    },
    icon: {
      type: String,
      default: ''
    }
  }
}
</script>
