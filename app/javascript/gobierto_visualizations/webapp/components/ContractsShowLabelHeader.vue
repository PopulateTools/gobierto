<template>
  <div class="visualizations-contracts-show__header__group">
    <i
      class="fas visualizations-contracts-show__icon"
      :class="'fa-' + icon"
    />
    <span class="visualizations-contracts-show__text">
      {{ label }}
    </span>
    <!-- `to` turns the value into an in-app link, for the rows pointing at
         another page of the viewer (the establishment tender of a derived
         contract). Without it the value is plain text, as everywhere else. -->
    <router-link
      v-if="to"
      :id="linkId"
      :to="to"
      class="visualizations-contracts-show__text visualizations-contracts-show__text__bold"
    >
      {{ value }}
    </router-link>
    <span
      v-else
      class="visualizations-contracts-show__text visualizations-contracts-show__text__bold"
    >
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
    },
    to: {
      type: Object,
      default: null
    },
    linkId: {
      type: String,
      default: null
    }
  }
}
</script>
