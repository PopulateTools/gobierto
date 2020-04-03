<template>
  <div>
    <textarea
      ref="queryEditor"
    />
    <div class="gobierto-data-sql-editor-footer">
      <div v-if="showMessages">
        <div v-if="showApiError">
          <span class="gobierto-data-sql-error-message">
            {{ stringError }}
          </span>
        </div>
        <div v-else>
          <span class="gobierto-data-sql-editor-footer-records">
            {{ numberRecords }} {{ labelRecords }}
          </span>
          <span class="gobierto-data-sql-editor-footer-time">
            {{ labelQueryExecuted }} {{ timeQuery }}ms
          </span>
        </div>
      </div>
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
    numberRows: {
      type: Number,
      required: true
    },
    currentQuery: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      labelGuide: I18n.t('gobierto_data.projects.guide') || '',
      labelQueryExecuted: I18n.t('gobierto_data.projects.queryExecuted') || '',
      labelRecords: I18n.t('gobierto_data.projects.records') || '',
      labelLoading: I18n.t('gobierto_data.projects.loading') || '',
      numberRecords: '',
      timeQuery: '',
      stringError: '',
      showMessages: true,
      showApiError: false,
      sqlAutocomplete: sqlKeywords,
      arrayMutated: [],
      autoCompleteKeys: [],
      recordsLoader: false,
      cmOption: {
        tabSize: 2,
        styleActiveLine: false,
        lineNumbers: false,
        styleSelectedText: false,
        line: true,
        foldGutter: true,
        mode: 'text/x-sql',
        hintOptions: {
          completeSingle: false,
          hint: {}
        },
        showCursorWhenSelecting: true,
        theme: 'default',
        autoIndent: true,
        extraKeys: {
          Ctrl: 'autocomplete'
        }
      }
    };
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
    this.$root.$on('recordsDuration', this.updateRecordsDuration);
    this.$root.$on('apiError', this.showError)
    this.$root.$on('showMessages', this.handleShowMessages)

    this.numberRecords = this.numberRows
  },
  mounted() {
    this.mergeTables()

    this.editor = CodeMirror.fromTextArea(this.$refs.queryEditor, this.cmOption)

    // update the editor content
    if (this.currentQuery) {
      this.setEditorValue(this.currentQuery)
    }

    this.cmOption.hintOptions.hint = this.hint

    this.editor.on("keypress", editor => {
      editor.showHint()

      if (this.saveQueryState === true) {
        this.$root.$emit('updateActiveSave', true, false);
      }
    })

    this.editor.on('focus', () => {
      this.$root.$emit('activeSave', false)
      this.$root.$emit('focusEditor')
    })

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
    updateRecordsDuration(values) {
      const { 0: numberRecords, 1: timeQuery } = values
      this.numberRecords = numberRecords
      this.timeQuery = timeQuery.toFixed(2)
    },
    saveQueryState(value) {
      this.saveQueryState = value;
    },
    setEditorValue(newCode) {
      this.editor.setValue(newCode)
    },
    handleShowMessages(showTrue, showLoader){
      this.recordsLoader = showLoader
      this.showMessages = false
      this.showMessages = showTrue
      this.showApiError = false
    },
    showError(message) {
      this.recordsLoader = false
      this.showMessages = true
      this.showApiError = true
      this.stringError = message
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
