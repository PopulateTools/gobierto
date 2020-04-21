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
                v-for="{ id, attributes: { sql, name, privacy_status }} in privateQueries"
                :key="id"
                class="gobierto-data-summary-queries-container"
                @mouseover="showSQLCode(sql)"
                @mouseleave="removeSQLCode()"
              >
                <router-link
                  :to="`/datos/${$route.params.id}/q/${id}`"
                  class="gobierto-data-summary-queries-container-name"
                >
                  {{ name }}
                </router-link>

                <div class="gobierto-data-summary-queries-container-icon">
                  <i
                    class="fas fa-trash-alt icons-your-queries"
                    style="color: var(--color-base);"
                    @click.stop="clickDeleteQueryHandler(id)"
                  />

                  <PrivateIcon
                    :is-closed="privacy_status === 'closed'"
                    class="icons-your-queries"
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
              v-for="{ id, attributes: { sql, name }} in publicQueries"
              :key="id"
              class="gobierto-data-summary-queries-container"
              @mouseover="showSQLCode(sql)"
              @mouseleave="removeSQLCode()"
            >
              <router-link
                :to="`/datos/${$route.params.id}/q/${id}`"
                class="gobierto-data-summary-queries-container-name"
              >
                {{ name }}
              </router-link>
            </div>
          </div>
        </Dropdown>
      </div>

      <div class="pure-u-1-2 border-color-queries">
        <p class="gobierto-data-summary-queries-sql-code">
          <transition name="fade">
            <textarea ref="querySnippet" />
          </transition>
        </p>
      </div>
    </div>
  </div>
</template>
<script>
import { Dropdown } from "lib/vue-components";
import Caret from "./Caret.vue";
import PrivateIcon from './PrivateIcon.vue';
import CodeMirror from "codemirror";
import "codemirror/mode/sql/sql.js";

export default {
  name: "Queries",
  components: {
    Caret,
    Dropdown,
    PrivateIcon
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
  mounted() {
    const cmOption = {
      tabSize: 2,
      styleActiveLine: false,
      lineNumbers: false,
      styleSelectedText: false,
      line: true,
      foldGutter: true,
      mode: "text/x-sql",
      showCursorWhenSelecting: true,
      theme: "default",
      autoIndent: true
    };

    console.log(this.sqlCode)

    this.editor = CodeMirror.fromTextArea(this.$refs.querySnippet, cmOption);
  },
  methods: {
    clickDeleteQueryHandler(id) {
      this.$root.$emit('deleteSavedQuery', id)
    },
    showSQLCode(code) {
      this.sqlCode = code
      console.log(this.sqlCode)
      this.editor.setValue(this.sqlCode);
    },
    removeSQLCode() {
      this.sqlCode = ''
      this.editor.setValue(this.sqlCode);
    }
  }
};
</script>
