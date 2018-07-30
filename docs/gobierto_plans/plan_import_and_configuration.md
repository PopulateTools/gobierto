## CSV File Structure
The CSV can use , or ; as column separator.

Requirements:
* There must be at least 2 columns named as `Level <n>`, where n are different integer numbers. The number order is considered: The `Level <n>` column with lower n value will be used to create root categories and the following columns ordered by n will create child categories of the previous ones.
* There must be at least a node column named `Node.Title` for the nodes. The string values of this column on each row will be used as `name` attribute of node for the default locale of the site the plan belongs to.
* All node column names with `Node.<field_name>` structure will be checked for each row:
  * If all node values are blank, the node will be ignored but the categories will be created without depending nodes
  * Otherwise, an error will raise unless `Node.Title` is not empty.

Optional:
* Other optional node columns which will be used for their attributes if present:
  * `Node.Status`: The value will be treated as String and stored in `status` for the default locale of the site the plan belongs to.
  * `Node.Progress`: The value will be converted to Float and stored in `progress` (something like "55.5%" or "55.5" will be converted to 55.5)
  * `Node.Start`: The value will be converted to date and stored in `starts_at`
  * `Node.End`: The value will be converted to date and stored in `ends_at`
* Remaining columns named with `Node.<custom_field>` will be stored in the node `options` JSON attribute under `custom_field` key.
* Any other column will be ignored

## Plan Configuration
JSON containing translations for each category level name and some other concerns, like:
* Options attributes to be shown translated in node card view
* Which options attributes has to be shown with defined translations

### Translations for each level of categories / nodes
Starting from 0 and ending with n, where n is the number of categories a set of n+1 `"level<i>"` keys are used to provide the translations in singular (under `"one"` key) and plural (under `"other"` key) of the categories for each level (the first n), the nodes (key `"level<n>"`) and the name for the nodes.
For example, for a Plan with 2 levels of categories:
```javascript
{
  "level0": {
    "one": {
      "es": "eje",
      "ca": "eix",
      "en": "axis"
    },
    "other": {
      "es": "ejes",
      "ca": "eixos",
      "en": "axes"
    }
  },
  "level1": {
    "one": {
      "es": "línea de actuación",
      "ca": "línia d'actuació",
      "en": "line of action"
    },
    "other": {
      "es": "líneas de actuación",
      "ca": "línies d'actuació",
      "en": "lines of action"
    }
  },
  "level2": {
    "one": {
      "es": "actuación",
      "ca": "actuació",
      "en": "action"
    },
    "other": {
      "es": "actuaciones",
      "ca": "actuacions",
      "en": "actions"
    }
  }
}
```
### First level categories images
Under the key `"level0_options"`, the logo for the categories of first level can be configured with an array of objects. Each object will contain the key `"slug"` with the category slug and the key `"logo"` with the url of the image. For example:
```javascript
{
  "level0_options": [
    {
      "slug": "economia",
      "logo": "https://example.com/logo1.png"
    },
    {
      "slug": "personas-y-familia",
      "logo": "https://example.com/logo1.png"
    }
  ]
}
```
### Options keys
Under `"option_keys"` the translations of the different keys stored in `options'. The keys translated here will be showed in a view activated with other configuration key described below. For example:
```javascript
{
  "option_keys": {
    "GOALS": {
      "es": "Objetivos",
      "ca": "Metes",
      "en": "Goals"
    },
    "DESCRIPTION": {
      "es": "Descripción",
      "ca": "Descripció",
      "en": "Description"
    },
    "TECHNICAL_SUPERVISOR_AREA": {
      "es": "Área de supervisor técnico",
      "ca": "Àrea de supervisió tècnica",
      "en": "Technical supervisor area"
    }
  }
}
```

### Other configuration keys
* `"show_table_header"`: If true, the tables showing nodes will have headers with the name of each attribute shown (currently name, starts_at, status and progress)
* `"open_node"`: If true, when clicking on a node a card view will be shown for the node, with the custom attributes defined in `"option_keys"` and some other like progress, starts_at, ends_at and status.
* `"hide_level0_counters"`: By default the categories of first level are shown enumerated. Set this to true to not display a number.
```javascript
{
  "show_table_header": false,
  "open_node": true,
  "hide_level0_counters": true
}
```
## Examples

* [Empty template with some columns](https://docs.google.com/spreadsheets/d/1_f9x_Uofjl0xOwpflA4d4NA-j7DBQRz1jqyfSpqVQCE/edit#gid=596026617)
