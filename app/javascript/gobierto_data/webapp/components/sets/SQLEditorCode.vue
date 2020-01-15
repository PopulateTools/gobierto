<template>
  <div>
    <div class="codemirror">
      <codemirror
        ref="myCm"
        v-model="code"
        :options="cmOption"
        @ready="onCmReady"
        @input="onCmCodeChange"
        @blur="formatCode"
      />
    </div>
    <div class="gobierto-data-sql-editor-footer">
      <span class="gobierto-data-sql-editor-footer-records">
        {{ numberRecords }} {{ labelRecords }}
      </span>
      <span class="gobierto-data-sql-editor-footer-time">
        {{ labelQueryExecuted }} {{ timeQuery }}s
      </span>
      <a
        href=""
        class="gobierto-data-sql-editor-footer-guide"
      >
        {{ labelGuide }}
      </a>
    </div>
  </div>
</template>
<script>
import sqlFormatter from "sql-formatter"
import 'codemirror/mode/sql/sql.js'
import 'codemirror/addon/selection/active-line.js'
import 'codemirror/addon/hint/show-hint.css'
import 'codemirror/addon/hint/show-hint.js'
import 'codemirror/addon/hint/sql-hint.js'
import { commands } from 'codemirror/src/edit/commands.js'
import 'codemirror/src/model/selection_updates.js'

export default {
  name: 'SQLEditorCode',
  data() {
    return {
      code: 'SELECT * FROM mobiliario_urbano',
      labelGuide: '',
      labelQueryExecuted: '',
      labelRecords: '',
      numberRecords: '1337',
      timeQuery: '0.1',
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
          tables: {}
        },
        showCursorWhenSelecting: true,
        theme: "default",
        autoIndent: true,
        extraKeys: {
          "Ctrl": "autocomplete"
        }
      }
    }
  },
  computed: {
    codemirror() {
      return this.$refs.myCm.codemirror
    }
  },
  created() {
    this.labelGuide = I18n.t("gobierto_data.projects.guide")
    this.labelQueryExecuted = I18n.t("gobierto_data.projects.queryExecuted")
    this.labelRecords = I18n.t("gobierto_data.projects.records")
    this.$root.$on("saveQueryState", this.saveQueryState);
  },
  mounted() {
    this.cm = this.$refs.myCm.codemirror
    this.commands = commands
    const tables = {
      "table_1": [],
      "table_2": [],
      "table_3": [],
      "table_4": [],
      "table_5": [],
      "table_6": []
    }
    window.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.keyCode == 32) {
        this.formatCode()
        this.cm.setCursor(this.cm.lineCount(), 0);
      }
    });

    this.cmOption.hintOptions.tables = tables
  },
  methods: {
    saveQueryState(value){
      this.saveQueryState = value
    },
    onCmReady(cm) {
      cm.on('keypress', () => {
        this.$root.$emit("activeSave", false);

        if (this.saveQueryState === true) {
          this.$root.$emit("updateActiveSave", true, false);
        }
        /*var options = {
          hint: function() {
            return {
              from: cm.getDoc().getCursor(),
              to: cm.getDoc().getCursor()
            }
          }
        }
        cm.showHint(options);*/
      })
    },
    formatCode() {
      this.commands.selectAll(this.cm)
      const formaterCode = sqlFormatter.format(this.code)
      this.cm.setValue(formaterCode)
    },
    runQuery() {
      let oneLine = this.code.replace(/\n/g, ' ');
      oneLine = oneLine.replace(/  +/g, ' ');
      alert('Run Query ' + oneLine)
    },
    onCmCodeChange(newCode) {
      this.code = newCode
      this.$root.$emit("updateCode", this.code);
    },
    saveCode() {
      const saveQuery = this.code
      this.arrayQuerys.push(saveQuery)
    }
  }
}
</script>
