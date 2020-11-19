<template>
  <div>
    <span class="dashboards-maker--aside__title">{{ titleLabel }}</span>

    <SmallCard
      v-for="card in cards"
      :key="card"
      :name="card"
    />

    <p class="dashboards-maker--aside__footer">
      {{ instructionsLabel }}
    </p>
  </div>
</template>

<script>
import SmallCard from "../components/SmallCard"
export default {
  name: "Aside",
  components: {
    SmallCard
  },
  data() {
    return {
      titleLabel: "Tarjetas disponibles",
      instructionsLabel: "⇧ Selecciona un tipo de tarjeta e incluyela en el área central ➞ \n\nLuego podrás configurarla.",
      cards: [
        "Semáforo",
        "Indicador",
        "Contenido HTML",
      ]
    }
  }
}
</script>