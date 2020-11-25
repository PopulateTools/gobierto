<template>
  <div class="widget">
    <div
      v-if="!edit"
      v-html="raw"
    />
    <textarea
      v-else
      v-model="text"
      class="widget__textarea"
      @change="handleChange"
    />
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
  },
  data() {
    return {
      text: this.raw
    }
  },
  methods: {
    handleChange({ target: { value } }) {
      this.$emit('change', { raw: value })
    }
  }
}
</script>