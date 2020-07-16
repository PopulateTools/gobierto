<template>
  <div class="mb2">
    <button
      v-for="button in buttons"
      disabled
    >
      {{ button }}
    </button>
  </div>
</template>

<script>
export default {
  name: "ButtonFilters",
  data() {
    return {
      // DEBUG: parametrizar
      buttons: ['Ver por categoria', 'Ver por proyectos', 'Ver por subprogramas']
    }
  }
}
</script>