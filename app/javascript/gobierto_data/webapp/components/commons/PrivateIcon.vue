<template>
  <i
    :class="isClosed ? 'fa-lock' : 'fa-lock-open'"
    :style="isClosed ? 'color: #D0021B;' : 'color: #A0C51D;'"
    class="fas"
  />
</template>

<script>
export default {
  name: 'PrivateIcon',
  props: {
    isClosed: {
      type: Boolean,
      default: false
    },
  }
}
</script>
