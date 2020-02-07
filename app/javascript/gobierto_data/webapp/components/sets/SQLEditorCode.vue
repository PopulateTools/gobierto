<template>
  <div>
    <div class="codemirror">
      <textarea
        ref="myCm"
        v-model="code"
      />
    </div>
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
          <a
            href=""
            class="gobierto-data-sql-editor-footer-guide"
          >
            {{ labelGuide }}
          </a>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
/*import sqlFormatter from 'sql-formatter';*/
import CodeMirror from "codemirror";
import 'codemirror/mode/sql/sql.js';
import 'codemirror/addon/selection/active-line.js';
import 'codemirror/addon/hint/show-hint.css';
import 'codemirror/addon/hint/show-hint.js';
import 'codemirror/addon/hint/sql-hint.js';
import 'codemirror/src/model/selection_updates.js';
import { sqlKeywords } from "./../../../lib/commons.js"

export default {
  name: 'SQLEditorCode',
  props: {
    tableName: {
      type: String,
      required: true
    },
    arrayColumns: {
      type: Array,
      required: true
    },
  },
  data() {
    return {
      editor: null,
      code: '',
      labelGuide: '',
      labelQueryExecuted: '',
      labelRecords: '',
      numberRecords: '',
      timeQuery: '',
      stringError: '',
      showMessages: true,
      showApiError: false,
      sqlAutocomplete: sqlKeywords,
      arrayMutated: [],
      autoCompleteKeys: [],
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
          hint: this.hint
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
  computed: {
    codemirror() {
      return this.$refs.myCm.codemirror;
    }
  },
  created() {
    this.labelGuide = I18n.t('gobierto_data.projects.guide');
    this.labelQueryExecuted = I18n.t('gobierto_data.projects.queryExecuted');
    this.labelRecords = I18n.t('gobierto_data.projects.records');
    this.$root.$on('saveQueryState', this.saveQueryState);
    this.$root.$on('recordsDuration', this.updateRecordsDuration);
    this.$root.$on('updateCode', this.updateCode)
    this.$root.$on('apiError', this.showError)
    this.$root.$on('showMessages', this.handleShowMessages)
    this.$root.$on('sendQueryCode', this.queryCode)
    this.$root.$emit('activateModalRecent')

    this.$root.$on('sendYourCode', this.queryCode);

    this.code = `SELECT * FROM ${this.tableName}`
  },
  mounted() {
    this.mergeTables()

    this.editor = CodeMirror.fromTextArea(this.$refs.myCm, this.cmOption)

    this.editor.on("keypress", editor => {
      editor.showHint()
      this.$root.$emit('activeSave', false);
      if (this.saveQueryState === true) {
        this.$root.$emit('updateActiveSave', true, false);
      }
    })

    this.editor.on('focus', editor => {
      this.code = editor.getValue()
      this.$root.$emit('activeSave', false)
      this.$root.$emit('activateModalRecent')
      this.$root.$emit('sendCode', this.code);
      this.$root.$emit('focusEditor', true)
    })

    this.editor.on('blur', () => {
      this.$root.$emit('focusEditor', false)
    })

    this.editor.on('change', editor => {
      this.code = editor.getValue()
      this.$root.$emit('sendCode', this.code);
    })
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
    queryCode(code){
      this.code = code
      this.editor.setValue(this.code)
    },
    updateRecordsDuration(values) {
      const { 0: numberRecords, 1: timeQuery } = values
      this.numberRecords = numberRecords
      this.timeQuery = timeQuery.toFixed(2)
    },
    saveQueryState(value) {
      this.saveQueryState = value;
    },
    inputCode() {
      this.$root.$emit('activeSave', false)
      this.$root.$emit('activateModalRecent')
      this.$root.$emit('sendCode', this.code);
    },
    formatCode() {
      //Convert to button or shortcut
      /*this.commands.selectAll(this.cm);
      const formaterCode = sqlFormatter.format(this.code);
      this.cm.setValue(formaterCode);*/
    },
    updateCode(newCode) {
      this.$root.$emit('sendCode', this.code);
      this.code = unescape(newCode)
      this.editor.setValue(this.code)
    },
    handleShowMessages(showTrue){
      this.showMessages = false
      this.showMessages = showTrue
      this.showApiError = false
    },
    showError(message) {
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
