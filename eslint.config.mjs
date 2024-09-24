import js from '@eslint/js';
import globals from 'globals';
import pluginVue from 'eslint-plugin-vue'

export default [
  js.configs.recommended,
  ...pluginVue.configs['flat/vue2-recommended'], // as long as we use Vue2
  {
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      globals: {
        ...globals.browser,
        ...globals.node,
        ...globals.jquery,
        ...globals.jest,
        ...globals.es2020,
        "Vue": true,
        "I18n": true,
        "jest/globals": true,
        "GobiertoAdmin": true,
        "User": true,
        "GobiertoPeople": true,
        "GobiertoBudgets": true,
        "GobiertoIndicators": true,
      }
    },
    "rules": {
      "no-multiple-empty-lines": ["error", { "max": 2, "maxEOF": 1 }],
      "no-multi-spaces": "error",
      "keyword-spacing": ["error", { "after": true, "before": true }],
      "no-trailing-spaces": "error",
      "object-curly-spacing": ["error", "always"],
      "no-console": "off"
    }
  }
]
