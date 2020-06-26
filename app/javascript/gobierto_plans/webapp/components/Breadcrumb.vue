<template>
  <div class="node-breadcrumb mb2">
    <router-link :to="{ name: 'home' }">
      {{ labelStarts }}
    </router-link>

    <template v-for="parent in parents">
      <router-link
        :key="parent.id"
        :to="{ name: 'categories', params: { id: parent.id } }"
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
    json: {
      type: Array,
      default: () => []
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
    const { last_level } = this.options
    const ITEMS = PlansStore.state.plainItems
    const parents = []

    const findParents = (model) => {
      const { level, attributes } = model

      // TODO: Si esta estructura cambia, es necesario adaptar este objeto
      const id = (level === last_level) ? attributes.category.id : attributes.term_id
      const parent = ITEMS.find(d => +d.id === id)

      if (parent) {
        parents.push(parent)
        findParents(parent)
      }
    }

    findParents(this.model)
    this.parents = parents.reverse()
  }
}
</script>