<template>
  <div class="node-breadcrumb mb2">
    <router-link :to="{ name: 'home' }">
      {{ labelStarts }}
    </router-link>

    <template v-for="level in currentLevel">
      <router-link
        :key="level"
        :to="{ name: 'categories' }"
      >
        <i class="fas fa-caret-right" />
        {{ getParent() }}
      </router-link>
      <!-- <a
        :key="level"
        @click.stop="setParent(level)"
      >
        <i class="fas fa-caret-right" />
        {{ (getParent(level).attributes || {}).title | translate }}
      </a> -->
    </template>
  </div>
</template>

<script>
import { translate } from "lib/shared"

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
      currentLevel: 0,
    }
  },
  created() {
    const { level } = this.model

    this.currentLevel = level
  },
  methods: {
    getParent() {

      // From uid, turno into array all parents, and drop last item (myself)
      var ancestors = _.dropRight(this.activeNode.uid.split(".")).map(Number);

      var current = this.json; // First item. ROOT item
      for (var i = 0; i < ancestors.length; i++) {
        if (i === breakpoint) {
          // If there is breakpoint, I get the corresponding ancestor set by breakpoint
          break;
        }

        if (!_.isArray(current)) {
          current = current.children;
        }
        current = current[ancestors[i]];
      }

      return current || {};
    },
    setParent() {
      // Initialize args
      var breakpoint =
        arguments.length > 0 && arguments[0] !== undefined
          ? arguments[0]
          : undefined;
      //hack 3rd level (3rd level has no SECTION)
      if (breakpoint === 3) breakpoint = breakpoint - 1;

      this.activeNode = this.getParent(breakpoint);
    }
  }
}
</script>