<template>
  <div class="container">
    <div class="container-editor">
      <div class="codemirror-toolbar">
        <button @click="formatCode()">Indentar</button>
        <button @click="saveCode()">Guardar</button>
        <button @click="queryRandom()">Query Random</button>
      </div>
      <div class="codemirror">
        <codemirror
          ref="myCm"
          v-model="code" :options="cmOption" @ready="onCmReady" @input="onCmCodeChange" @blur="formatCode">
          >
        </codemirror>
      </div>
      <button class="editor-btn-execute" @click="execute()">Ejecutar</button>
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
  name: 'CodeMirror',
  props: {
    msg: String
  },
  data() {
    const code =
      `SELECT
  COUNT(*) AS lines,
  COUNT(*) FILTER (
    WHERE
      TO_NUMBER(t.quantity, '999999999999') > 0
      AND TO_NUMBER(t.value, '999999999999') > 0
  ) AS loadable_lines,
  COUNT(*) FILTER (
    WHERE
      t.type != 'import'
      AND t.type != 'export'
  ) AS invalid_type,
  STRING_AGG(m_commodity.hs_code, '^') AS missing_hs_codes,
  STRING_AGG(m_country.country, '^') AS missing_countries,
  STRING_AGG(m_unit.unit, '^') AS missing_units
FROM
  staging_temp AS t
  LEFT JOIN m_commodity ON (m_commodity.id = t.id)
  LEFT JOIN m_country ON (m_country.id = t.id)
  LEFT JOIN m_unit ON (m_unit.id = t.id)`

    return {
      code,
      arrayQuerys: [],
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
        // eslint-disable-next-line no-console
      }
    });

    this.cmOption.hintOptions.tables = tables
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
<style>
.CodeMirror-code {
  text-align: left;
}

.container {
  width: 80%;
  margin: 0 auto;
}

.container-editor {
  width: 50%;
  margin: 0 auto;
}

.codemirror {
  border: 1px solid #ccc;
  border-radius: 4px;
  border-top-left-radius: 0;
  border-top-right-radius: 0;
}

.CodeMirror {
  background-color: #FAFAFA !important;
  border-radius: 4px;
  border-top-left-radius: 0;
  border-top-right-radius: 0;
  padding: .5rem;
  height: auto !important;
}

button {
  background-color: transparent;
  border-radius: 4px;
  border: 0;
  padding: .5rem;
  cursor: pointer;
  margin-right: 1rem;
  font-size: 12px;
  color: #666;
}

.codemirror-toolbar {
  background-color: #ECEAEA;
  border: 1px solid #ccc;
  border-bottom: 0;
  border-radius: 4px;
  border-bottom-left-radius: 0;
  border-bottom-right-radius: 0;
  padding: .5rem;
}

.btn-viz {
  border-bottom: 3px solid #0668C9;
  border-radius: 0;
  margin-bottom: 1rem;
}
</style>
