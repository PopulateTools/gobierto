<template>
  <div
    class="widget"
    v-html="raw"
  />
</template>

<script>
export default {
  name: "WidgetHTML",
  props: {
    raw: {
      type: String,
      default: "<h3>Nuevo dashboard - escribe aquí el texto de cabecera</h3><p>También puedes escribir una descripción</p>"
    }
  }
}
</script>