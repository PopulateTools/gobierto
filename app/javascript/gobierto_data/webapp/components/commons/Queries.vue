<template>
  <div class="gobierto-data-summary-queries">
    <div class="gobierto-data-summary-queries-panel pure-g">
      <div class="pure-u-1-2 gobierto-data-summary-queries-panel-dropdown">
        <Dropdown @is-content-visible="showPrivateQueries = !showPrivateQueries">
          <template v-slot:trigger>
            <h3 class="gobierto-data-summary-queries-panel-title">
              <Caret :rotate="showPrivateQueries" />

              {{ labelYourQueries }} ({{ privateQueries.length }})
            </h3>
          </template>

          <div>
            <transition-group name="fade">
              <div
                v-for="item in privateQueries"
                :key="item.id"
                class="gobierto-data-summary-queries-container"
                @mouseover="sqlCode = item.attributes.sql"
                @mouseleave="sqlCode = null"
              >
                <router-link
                  :to="`/datos/${$route.params.id}/q/${item.id}`"
                  class="gobierto-data-summary-queries-container-name"
                >
                  {{ item.attributes.name }}
                </router-link>

                <div class="gobierto-data-summary-queries-container-icon">
                  <i
                    class="fas fa-trash-alt icons-your-queries"
                    style="color: var(--color-base);"
                    @click="deleteQuery(item.id)"
                  />
                  <i
                    v-if="item.attributes.privacy_status === 'closed'"
                    style="color: #D0021B"
                    class="fas fa-lock icons-your-queries"
                  />
                  <i
                    v-else
                    style="color: rgb(160, 197, 29)"
                    class="fas fa-lock-open icons-your-queries"
                  />
                </div>
              </div>
            </transition-group>
          </div>
        </Dropdown>

        <Dropdown @is-content-visible="showFavQueries = !showFavQueries">
          <template v-slot:trigger>
            <h3 class="gobierto-data-summary-queries-panel-title">
              <Caret :rotate="showFavQueries" />

              <!-- TODO: Favorite Queries -->
              {{ labelFavs }} ({{ 0 }})
            </h3>
          </template>

          <!-- TODO: Favorite Queries -->
          <div />
        </Dropdown>

        <Dropdown @is-content-visible="showPublicQueries = !showPublicQueries">
          <template v-slot:trigger>
            <h3 class="gobierto-data-summary-queries-panel-title">
              <Caret :rotate="showPublicQueries" />

              {{ labelAll }} ({{ publicQueries.length }})
            </h3>
          </template>

          <div>
            <div
              v-for="(item, index) in publicQueries"
              :key="index"
              class="gobierto-data-summary-queries-container"
              @mouseover="sqlCode = item.attributes.sql"
              @mouseleave="sqlCode = null"
            >
              <router-link
                :to="`/datos/${$route.params.id}/q/?sql=${item.attributes.sql}`"
                class="gobierto-data-summary-queries-container-name"
              >
                {{ item.attributes.name }}
              </router-link>
            </div>
          </div>
        </Dropdown>
      </div>

      <div class="pure-u-1-2 border-color-queries">
        <p class="gobierto-data-summary-queries-sql-code">
          <span v-if="sqlCode"> {{ sqlCode }}</span>
        </p>
      </div>
    </div>
  </div>
</template>
<script>
import { Dropdown } from "lib/vue-components";
import Caret from "./Caret.vue";

export default {
  name: "Queries",
  components: {
    Caret,
    Dropdown
  },
  props: {
    privateQueries: {
      type: Array,
      required: true
    },
    publicQueries: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      labelYourQueries: I18n.t("gobierto_data.projects.yourQueries") || "",
      labelFavs: I18n.t("gobierto_data.projects.favs") || "",
      labelAll: I18n.t("gobierto_data.projects.all") || "",
      sqlCode: null,
      showPrivateQueries: true,
      showFavQueries: true,
      showPublicQueries: true,
    };
  },
  methods: {
    deleteQuery(id) {
      this.$root.$emit('deleteSavedQuery', id)
    }
  }
};
</script>
