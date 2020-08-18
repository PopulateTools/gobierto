<template>
  <div class="gobierto-data-visualization--card">
    <div class="gobierto-data-visualization--aspect-ratio-16-9">
      <div class="gobierto-data-visualization--content">
        <h4 class="gobierto-data-visualization--title">
          <slot name="title" />
        </h4>
        <slot />
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "CardVisualization",
}
</script>
