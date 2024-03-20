<template>
  <div class="planification-buttons">
    <router-link
      v-if="buttons.length"
      :to="{ name: routes.PLAN, params: { ...$route.params } }"
      class="planification-buttons__button"
      :class="{ 'is-active': isActiveButton }"
      tag="button"
    >
      {{ labelViewBy }} <strong>{{ labelCategory }}</strong>
    </router-link>
    <router-link
      v-for="{ id, name } in buttons"
      :key="id"
      :to="{ name: routes.TABLE, params: { ...$route.params, id } }"
      class="planification-buttons__button"
      :class="{ 'is-active': id === currentId && !isActiveButton }"
      tag="button"
    >
      {{ labelViewBy }} <strong>{{ name | translate }}</strong>
    </router-link>
  </div>
</template>

<script>
import { PlansStore } from "../lib/store";
import { translate } from "lib/vue/filters";
import { routes } from "../lib/router";

export default {
  name: "ButtonFilters",
  filters: {
    translate
  },
  props: {
    options: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      buttons: [],
      labelViewBy: I18n.t("gobierto_plans.plan_types.show.view_by") || '',
      labelCategory: I18n.t("gobierto_plans.plan_types.show.category") || ''
    }
  },
  computed: {
    routes() {
      return routes
    },
    currentId() {
      const { id } = this.$route.params
      return id
    },
    isActiveButton() {
      const { name: current, meta: { button } } = this.$route
      return [current, button].includes(routes.PLAN)
    }
  },
  created() {
    const { meta } = PlansStore.state
    const { fields_to_show_as_filters = [] } = this.options

    this.buttons = meta.reduce((acc, { attributes }) => {
      const { uid, field_type, name_translations } = attributes
      if (field_type === "vocabulary_options" && fields_to_show_as_filters.includes(uid)) {
        acc.push({ id: uid, name: name_translations })
      }
      return acc
    }, [])
  }
}
</script>
