<template>
  <div class="widget">
    <div
      v-if="!edit"
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
      default: "<h3>Nuevo widget HTML - escribe aquí el texto de cabecera</h3>\n<p>También puedes escribir una descripción</p>"
    },
    edit: {
      type: Boolean,
      default: false
    }
  }
}
</script>