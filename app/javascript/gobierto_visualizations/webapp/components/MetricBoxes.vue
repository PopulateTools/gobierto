<template>
  <div class="metric_boxes mt4">
    <div class="metric_box">
      <div class="inner nomargin">
        <div class="pure-g p_1">
          <slot />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "MetricBoxes"
}
</script>
