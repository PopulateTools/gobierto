<template>
  <div class="pure-u-1 pure-u-lg-1-3">
    <h3 :style="!labels[0] && { visibility: 'hidden' }">
      {{ labels[0] || "&nbsp;" }}
    </h3>

    <div class="metric m_b_1">
      <span :id="`number-${type}`" />
    </div>
    <p class="m_t_0">
      {{ labels[1] }}
    </p>
    <div class="metric m_b_1">
      <small><span :id="`sum-${type}`" /></small>
    </div>

    <div class="pure-g">
      <div class="pure-u-1-2 explanation explanation--relative">
        {{ labels[2] }}
        <strong class="d_block"><span :id="`mean-${type}`" /></strong>
      </div>

      <div class="pure-u-1-2 explanation explanation--relative">
        {{ labels[3] }}
        <strong class="d_block"><span :id="`median-${type}`" /></strong>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "MetricBox",
  props: {
    type: {
      type: String,
      default: ""
    },
    labels: {
      type: Array,
      default: () => []
    },
  }
}
</script>
