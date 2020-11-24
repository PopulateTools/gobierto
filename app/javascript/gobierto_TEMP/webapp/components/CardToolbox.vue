<template>
  <div class="dashboards-maker--card__toolbox">
    <Button
      icon="edit"
      class="dashboards-maker--button__square"
    />
    <Button
      icon="trash"
      class="dashboards-maker--button__square"
    />
  </div>
</template>

<script>
import Button from "./Button"

export default {
  name: "CardToolbox",
  components: {
    Button
  }
};
</script>
