<template>
  <div class="node-breadcrumb mb2">
    <router-link :to="{ name: routes.PLAN, params: { ...$route.params } }">
      {{ labelStarts }}
    </router-link>

    <template v-for="{ id, attributes: { name } = {}} in parents">
      <router-link
        :key="id"
        :to="{ name: routes.CATEGORIES, params: { ...params, id } }"
      >
        <i class="fas fa-caret-right" />
        {{ name }}
      </router-link>
    </template>
  </div>
</template>

<script>
import { translate } from '../../../lib/vue/filters';
import { routes } from '../lib/router';
import { PlansStore } from '../lib/store';

export default {
  name: "Breadcrumb",
  filters: {
    translate
  },
  props: {
    model: {
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
  computed: {
    routes() {
      return routes
    },
    params() {
      return this.$route.params
    }
  },
  created() {
    const { plainItems, options } = PlansStore.state
    const { last_level, max_category_level } = options
    const parents = []

    const findParents = (model) => {
      const { level, attributes: { category_id, term_id } = {} } = model

      const id = (level === last_level) ? category_id : term_id
      const parent = plainItems.find(d => +d.id === id)

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
