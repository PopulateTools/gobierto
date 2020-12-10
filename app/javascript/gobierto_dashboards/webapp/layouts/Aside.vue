<template>
  <div>
    <span class="dashboards-maker--aside__title">{{ titleLabel }}</span>

    <slot />

    <p class="dashboards-maker--aside__footer">
      {{ instructionsLabel }}
    </p>
  </div>
</template>

<script>
export default {
  name: "Aside",
  data() {
    return {
      titleLabel: "Tarjetas disponibles",
      instructionsLabel: "⇧ Selecciona un tipo de tarjeta e incluyela en el área central ➞ \n\nLuego podrás configurarla.",
    }
  }
}
</script>