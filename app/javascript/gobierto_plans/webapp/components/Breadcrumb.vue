<template>
  <div class="node-breadcrumb mb2">
    <router-link :to="{ name: 'home', params: { ...$route.params } }">
      {{ labelStarts }}
    </router-link>

    <template v-for="parent in parents">
      <router-link
        :key="parent.id"
        :to="{ name: 'categories', params: { ...$route.params, id: parent.id } }"
      >
        <i class="fas fa-caret-right" />
        {{ parent.attributes.name }}
      </router-link>
    </template>
  </div>
</template>

<script>
import { translate } from "lib/shared"
import { PlansStore } from "../lib/store";

export default {
  name: "Breadcrumb",
  filters: {
    translate
  },
  props: {
    model: {
      type: Object,
      default: () => {}
    },
    options: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      labelStarts: I18n.t("gobierto_plans.plan_types.show.starts") || "",
      parents: []
    }
  },
  created() {
    const { last_level, max_category_level } = this.options
    const ITEMS = PlansStore.state.plainItems
    const parents = []

    const findParents = (model) => {
      const { level, attributes: { category_id, term_id } = {} } = model

      const id = (level === last_level) ? category_id : term_id
      const parent = ITEMS.find(d => +d.id === id)

      if (parent) {
        parents.push(parent)
        findParents(parent)
      }
    }

    findParents(this.model)

    // filter the last category, since the view is shared with the next to last category.
    // then, reverse the items in order to show them from minor level to higher
    this.parents = parents.filter(({ attributes: { level } = {} }) => level !== max_category_level ).reverse()
  }
}
</script>