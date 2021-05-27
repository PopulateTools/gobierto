<template>
  <div>
    <label
      class="helper-screenreader"
      for="queryEditor"
    >{{ labelEditor }}</label>
    <textarea
      id="queryEditor"
      ref="queryEditor"
    />
    <div class="gobierto-data-sql-editor-footer">
      <template v-if="queryError">
        <span class="gobierto-data-sql-error-message">
          {{ queryError }}
        </span>
      </template>

      <template v-else>
        <span class="gobierto-data-sql-editor-footer-time">
          {{ labelQueryExecuted }} {{ queryDurationParsed }}ms
        </span>
      </template>
    </div>
    <a
      href=""
      class="gobierto-data-sql-editor-footer-guide"
    >
      {{ labelGuide }}
    </a>
  </div>
</template>
<script>
import CodeMirror from "codemirror";
import "codemirror/mode/sql/sql.js";
import "codemirror/addon/selection/active-line.js";
import "codemirror/addon/hint/show-hint.css";
import "codemirror/addon/hint/show-hint.js";
import "codemirror/addon/hint/sql-hint.js";
import "codemirror/src/model/selection_updates.js";
import { sqlKeywords } from "./../../../../lib/commons.js";

export default {
  name: "SQLEditorCode",
  props: {
    objectColumns: {
      type: Object,
      required: true
    },
    queryStored: {
      type: String,
      default: ""
    },
    queryDuration: {
      type: Number,
      default: 0
    },
    queryError: {
      type: String,
      default: null
    },
    tableName: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      labelGuide: I18n.t("gobierto_data.projects.guide") || "",
      labelQueryExecuted: I18n.t("gobierto_data.projects.queryExecuted") || "",
      labelRecords: I18n.t("gobierto_data.projects.records") || "",
      labelEditor: I18n.t("gobierto_data.accessibility.editor") || "",
      sqlAutocomplete: sqlKeywords,
      arrayMutated: [],
      autoCompleteKeys: [],
      tableNameAutocomplete: []
    };
  },
  computed: {
    queryDurationParsed() {
      return this.queryDuration.toLocaleString();
    }
  },
  watch: {
    queryStored(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.setEditorValue(newValue);
      }
    }
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
      hintOptions: {
        completeSingle: false,
        hint: this.hint
      },
      showCursorWhenSelecting: true,
      theme: "default",
      autoIndent: true,
      extraKeys: {
        Ctrl: "autocomplete"
      },
      screenReaderLabel: "queryEditor"
    };

    this.editor = CodeMirror.fromTextArea(this.$refs.queryEditor, cmOption);

    // update the editor content
    if (this.queryStored) {
      this.setEditorValue(this.queryStored);
    }

    // metaKey + keyUp doesn't work with MacOS
    // https://stackoverflow.com/questions/11818637/why-does-javascript-drop-keyup-events-when-the-metakey-is-pressed-on-mac-browser
    this.editor.on("keydown", this.onKeyDown);
    // This event detects any changes in the editor
    this.editor.on("change", this.onChange);
    // We need this event to enable autocomplete(hint)
    this.editor.on("keyup", this.onKeyUp);
  },
  methods: {
    onKeyUp(editor, e) {
      const {
        state: {
          completionActive: isEditorActive
        }
      } = editor

      // Show autocomplete only when a letter key is pressed
      if (!isEditorActive && e.keyCode > 64 && e.keyCode < 91) {
        editor.showHint({ completeSingle: false })
      }

      // Enabled saved and fork button while typping on editor
      this.$root.$emit('disabledStringSavedQuery', false)
      this.$root.$emit('enableSavedButton')
      this.$root.$emit('enabledForkPrompt')
      this.$root.$emit('enabledRevertButton')
      this.$root.$emit("isQuerySavingPromptVisible", true);
    },
    onChange(editor) {
      this.mergeTables();
      const value = editor.getValue();
      this.$root.$emit("setCurrentQuery", value);
    },
    onKeyDown(editor, e) {
      this.mergeTables();
      // keyUp event to stop "c|r" open modals, but allow ctrl+enter (or cmd+enter) to run query
      if (!((e.keyCode == 10 || e.keyCode == 13) && (e.ctrlKey || e.metaKey))) {
        e.stopPropagation();
      }
    },
    mergeTables() {
      const sizeObjectColumns = Object.keys(this.objectColumns);

      for (let i = 0; i < sizeObjectColumns.length; i++) {
        this.arrayMutated[i] = {
          className: "table",
          text: sizeObjectColumns[i]
        };
      }
      this.autoCompleteKeys = [
        ...this.arrayMutated,
        ...this.sqlAutocomplete,
        {
          className: "dataset",
          text: this.tableName
      }];
    },
    setEditorValue(newCode) {
      const pos = this.editor.getCursor();
      this.editor.setValue(newCode);
      this.editor.setCursor(pos);
    },
    suggest(searchString) {
      let token = searchString;
      if (searchString.startsWith(".")) token = searchString.substring(1);
      else token = searchString.toLowerCase();
      let resu = [];
      let N = this.autoCompleteKeys.length;

      for (let i = 0; i < N; i++) {
        let keyword = this.autoCompleteKeys[i].text.toLowerCase();
        let suggestion = null;
        if (keyword.startsWith(token)) {
          suggestion = Object.assign(
            { score: N + (N - i) },
            this.autoCompleteKeys[i]
          );
        } else if (keyword.includes(token)) {
          suggestion = Object.assign(
            { score: N - i },
            this.autoCompleteKeys[i]
          );
        }
        if (suggestion) resu.push(suggestion);
      }

      if (searchString.startsWith(".")) {
        resu.forEach(s => {
          if (s.className === "table") {
            s.score += N;
            s.text = `.${s.text}`
          } else if (s.className === "sql") {
            s.score -= N;
          }
          return s;
        });
      }

      return resu.sort((a, b) => b.score - a.score);
    },
    hint(editor) {
      const cur = editor.getCursor();
      const token = editor.getTokenAt(cur);
      const searchString = token.string;

      return {
        list: this.suggest(searchString),
        from: CodeMirror.Pos(cur.line, token.start),
        to: CodeMirror.Pos(cur.line, token.end)
      };
    }
  }
};
</script>
