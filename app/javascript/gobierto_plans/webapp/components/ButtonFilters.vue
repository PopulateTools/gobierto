<template>
  <div class="planification-buttons">
    <router-link
      :to="{ path: $root.$data.baseurl }"
      class="planification-buttons__button"
      tag="button"
    >
      {{ labelViewBy }} <strong>{{ labelCategory }}</strong>
    </router-link>
    <router-link
      v-for="{ id, name } in buttons"
      :key="id"
      :to="{ path: `${$root.$data.baseurl}/tabla/${id}` }"
      class="planification-buttons__button"
      tag="button"
    >
      {{ labelViewBy }} <strong>{{ name | translate }}</strong>
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
      buttons: [],
      labelViewBy: I18n.t("gobierto_plans.plan_types.show.view_by") || '',
      labelCategory: I18n.t("gobierto_plans.plan_types.show.category") || ''
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