<template>
  <div>
    <div class="gobierto-data-sql-editor">
      <div class="gobierto-data-sql-editor-toolbar">
        <Button
          :text="undefined"
          icon="times"
          color="var(--color-base)"
          background="#fff"
          icon-color="var(--color-base)"
        />
        <Button
          :text="labelRecents"
          icon="history"
          color="var(--color-base)"
          background="#fff"
          icon-color="var(--color-base)"
        />
        <Button
          :text="labelQueries"
          icon="list"
          color="var(--color-base)"
          background="#fff"
          icon-color="var(--color-base)"
        />
        <Button
          :text="labelSave"
          icon="save"
          color="var(--color-base)"
          background="#fff"
          icon-color="var(--color-base)"
        />
        <Button
          :text="labelRunQuery"
          icon="play"
          color="var(--color-base)"
          background="#fff"
          icon-color="var(--color-base)"
          @click="execute()"
        />
      </div>
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
    </div>
  </div>
</template>
<script>
import Button from "./../commons/Button.vue";
import sqlFormatter from "sql-formatter"
import 'codemirror/mode/sql/sql.js'
import 'codemirror/addon/selection/active-line.js'
import 'codemirror/addon/hint/show-hint.css'
import 'codemirror/addon/hint/show-hint.js'
import 'codemirror/addon/hint/sql-hint.js'
import { commands } from 'codemirror/src/edit/commands.js'
import 'codemirror/src/model/selection_updates.js'

export default {
  name: 'CodeMirror',
  components: {
    Button
  },
  data() {
    const code =
      `SELECT * FROM mobiliario_urbano`
    return {
      code,
      arrayQuerys: [],
      labelSave: '',
      labelRecents: '',
      labelQueries: '',
      labelRunQuery: '',
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
  created() {
    this.labelSave = I18n.t("gobierto_data.projects.save")
    this.labelRecents = I18n.t("gobierto_data.projects.recents")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelRunQuery = I18n.t("gobierto_data.projects.runQuery")
  },
  methods: {
    onCmReady(cm) {
      cm.on('keypress', () => {
        cm.showHint()
      })
    },
    formatCode() {
      this.commands.selectAll(this.cm)
      const formaterCode = sqlFormatter.format(this.code)
      this.cm.setValue(formaterCode)
    },
    execute() {
      let oneLine = this.code.replace(/\n/g, ' ');
      oneLine = oneLine.replace(/  +/g, ' ');
      alert('Ejecutando consulta ' + oneLine)
    },
    onCmCodeChange(newCode) {
      this.code = newCode
    },
    saveCode() {
      const saveQuery = this.code
      this.arrayQuerys.push(saveQuery)
    },
    queryRandom() {
      this.commands.selectAll(this.cm)
      this.cm.setValue(this.arrayQuerys[0])
    }
  }
}
</script>
