<template>
  <div class="gobierto-table">
    <table />
  </div>
</template>
<script>
export default {
  name: 'TableHeader',
  props: {
    data: {
      type: Array,
      default: () => []
    }
  }
}

</script>
