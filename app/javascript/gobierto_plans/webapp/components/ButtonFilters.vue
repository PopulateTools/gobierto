<template>
  <div class="planification-buttons">
    <router-link
      v-if="buttons.length"
      :to="{ path: $root.$data.baseurl }"
      class="planification-buttons__button"
      :class="{ 'is-active': isComponentHome }"
      tag="button"
    >
      {{ labelViewBy }} <strong>{{ labelCategory }}</strong>
    </router-link>
    <router-link
      v-for="{ id, name } in buttons"
      :key="id"
      :to="{ path: `${$root.$data.baseurl}/tabla/${id}` }"
      class="planification-buttons__button"
      :class="{ 'is-active': id === currentId }"
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
    currentId() {
      const { id } = this.$route.params
      return id
    },
    isComponentHome() {
      return ['home', 'categories', 'projects'].includes(this.$route.name)
    }
  },
  created() {
    const { meta } = PlansStore.state
    const { fields_to_show_as_filters = [] } = this.options

    this.buttons = meta.reduce((acc, { attributes }) => {
      const { uid, field_type, name_translations } = attributes
      if (field_type === 'vocabulary_options' && fields_to_show_as_filters.includes(uid)) {
        acc.push({ id: uid, name: name_translations })
      }
      return acc
    }, [])
  }
}
</script>