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
      titleLabel: I18n.t("gobierto_dashboards.available_cards") || "",
      instructionsLabel: I18n.t("gobierto_dashboards.instructions") || "",
    }
  }
}
</script>