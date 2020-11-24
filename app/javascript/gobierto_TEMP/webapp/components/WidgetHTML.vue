<template>
  <div class="widget">
    <div
      v-if="!edition"
      v-html="raw"
    />
    <textarea
      v-else
      class="widget__textarea"
    >{{ raw }}</textarea>
  </div>
</template>

<script>
export default {
  name: "WidgetHTML",
  props: {
    raw: {
      type: String,
      default: "<h3>Nuevo dashboard - escribe aquí el texto de cabecera</h3><p>También puedes escribir una descripción</p>"
    },
    edition: {
      type: Boolean,
      default: false
    }
  }
}
</script>