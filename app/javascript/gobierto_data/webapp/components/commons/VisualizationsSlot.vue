<template>
  <div class="gobierto-data-visualization--card">
    <div class="gobierto-data-visualization--aspect-ratio-16-9">
      <div class="gobierto-data-visualization--content">
        <h4 class="gobierto-data-visualization--title">
          {{ name }}
        </h4>
        <slot name="visualization" />
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "VisualizationSlot",
  props: {
    name: {
      type: String,
      default: ''
    }
  }
}
</script>
