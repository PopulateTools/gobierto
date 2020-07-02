<template>
  <div class="mb2">
    <router-link
      :to="{ path: $root.$data.baseurl }"
      tag="button"
    >
      CAteogría
    </router-link>
    <router-link
      v-for="{ id, name } in buttons"
      :key="id"
      :to="{ path: `${$root.$data.baseurl}/tabla/${id}` }"
      tag="button"
    >
      {{ name | translate }}
    </router-link>
  </div>
</template>

<script>
import { PlansStore } from "../lib/store";
import { translate } from "lib/shared";

export default {
  name: "ButtonFilters",
  filters: {
    translate
  },
  data() {
    return {
      buttons: []
    }
  },
  created() {
    const { meta } = PlansStore.state
    this.buttons = meta.reduce((acc, { attributes }) => {
      const { uid, field_type, name_translations } = attributes
      if (field_type === 'vocabulary_options') {
        acc.push({ id: uid, name: name_translations })
      }
      return acc
    }, [])
  }
}
</script>