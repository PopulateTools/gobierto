<template>
  <div>
    <textarea
      ref="queryEditor"
    />
    <div class="gobierto-data-sql-editor-footer">
      <template v-if="queryError">
        <span class="gobierto-data-sql-error-message">
          {{ queryError }}
        </span>
      </template>

      <template v-else>
        <span class="gobierto-data-sql-editor-footer-records">
          {{ queryNumberRows }} {{ labelRecords }}
        </span>
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
import 'codemirror/mode/sql/sql.js';
import 'codemirror/addon/selection/active-line.js';
import 'codemirror/addon/hint/show-hint.css';
import 'codemirror/addon/hint/show-hint.js';
import 'codemirror/addon/hint/sql-hint.js';
import 'codemirror/src/model/selection_updates.js';
import { sqlKeywords } from "./../../../../lib/commons.js"

export default {
  name: 'SQLEditorCode',
  props: {
    tableName: {
      type: String,
      required: true
    },
    arrayColumns: {
      type: Object,
      required: true
    },
    currentQuery: {
      type: String,
      default: ''
    },
    queryNumberRows: {
      type: Number,
      default: 0
    },
    queryDuration: {
      type: Number,
      default: 0
    },
    queryError: {
      type: String,
      default: null
    },
  },
  data() {
    return {
      labelGuide: I18n.t('gobierto_data.projects.guide') || '',
      labelQueryExecuted: I18n.t('gobierto_data.projects.queryExecuted') || '',
      labelRecords: I18n.t('gobierto_data.projects.records') || '',
      labelLoading: I18n.t('gobierto_data.projects.loading') || '',
      sqlAutocomplete: sqlKeywords,
      arrayMutated: [],
      autoCompleteKeys: []
    };
  },
  computed: {
    queryDurationParsed() {
      return this.queryDuration.toLocaleString()
    }
  },
  watch: {
    currentQuery(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.setEditorValue(newValue)
      }
    }
  },
  created() {
    this.$root.$on('saveQueryState', this.saveQueryState);
  },
  mounted() {
    this.mergeTables()

    const cmOption = {
        tabSize: 2,
        styleActiveLine: false,
        lineNumbers: false,
        styleSelectedText: false,
        line: true,
        foldGutter: true,
        mode: 'text/x-sql',
        hintOptions: {
          completeSingle: false,
          hint: this.hint
        },
        showCursorWhenSelecting: true,
        theme: 'default',
        autoIndent: true,
        extraKeys: {
          Ctrl: 'autocomplete'
        }
      }

    this.editor = CodeMirror.fromTextArea(this.$refs.queryEditor, cmOption)

    // update the editor content
    if (this.currentQuery) {
      this.setEditorValue(this.currentQuery)
    }

    this.editor.on("keypress", editor => {
      editor.showHint()

      // every single time the editor is modified, we store the query
      this.$root.$emit('reloadCurrentQuery', editor.getValue());

      if (this.saveQueryState === true) {
        this.$root.$emit('updateActiveSave', true, false);
      }
    })

    this.editor.on('focus', () => this.$root.$emit('focusEditor'))
    this.editor.on('blur', () => this.$root.$emit('blurEditor'))
  },
  methods: {
    mergeTables(){
      for (let i = 0; i < this.arrayColumns.length; i++) {
        this.arrayMutated[i] = {
          className: 'table',
          text: this.arrayColumns[i]
        }
      }
      this.autoCompleteKeys = [ ...this.arrayMutated, ...this.sqlAutocomplete]
    },
    saveQueryState(value) {
      this.saveQueryState = value;
    },
    setEditorValue(newCode) {
      this.editor.setValue(newCode)
    },
    suggest(searchString) {
      let token = searchString
      if (searchString.startsWith(".")) token = searchString.substring(1)
      else token = searchString.toLowerCase()
      let resu = []
      let N = this.autoCompleteKeys.length

      for (let i = 0; i < N; i++) {
        let keyword = this.autoCompleteKeys[i].text.toLowerCase()
        let suggestion = null
        if (keyword.startsWith(token)) {
          suggestion = Object.assign({ score: N + (N - i) }, this.autoCompleteKeys[i])
        } else if (keyword.includes(token)) {
          suggestion = Object.assign({ score: N - i }, this.autoCompleteKeys[i])
        }
        if (suggestion) resu.push(suggestion)
      }

      if (searchString.startsWith(".")) {
        resu.forEach(s => {
          if (s.className == "column") s.score += N
          else if (s.className == "sql") s.score -= N
          return s
        })
      }
      return resu.sort((a, b) => b.score - a.score);
    },
    hint(editor) {
      let cur = editor.getCursor();
      let token = editor.getTokenAt(cur);
      let searchString = token.string;
      return {
        list: this.suggest(searchString),
        from: CodeMirror.Pos(cur.line, token.start),
        to: CodeMirror.Pos(cur.line, token.end)
      };
    }
  }
}
</script>
