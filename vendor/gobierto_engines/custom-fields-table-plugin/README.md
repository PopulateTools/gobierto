# Table Custom Field Plugin Engine

The purpose of this engine is to define a plugin for generic tables using SlickGrid. The definition of colums
can be set in the options of the plugin

## Usage

* Install the plugin.
* Define a plugin custom field of type "Table".
* A text area for options will appear. Use this section to define the columns.
* Each column requires:
  * An id
  * Name translations
  * A type: There are 5 allowed types: `text`, `integer`, `float`, `date` and `vocabulary`.
  * If the column is of type vocabulary the path of an endpoint to get the vocabulary info must be provided

Example:

```json
{
  plugin_configuration: {
    columns: [
      {
        "id": "person",
        "name_translations": { es: "Persona", en: "Person" },
        "type": "text"
      },
      {
        "id": "phone_number",
        "name_translations": { es: "Número de teléfono", en: "Phone number" },
        "type": "integer"
      },
      {
        "id": "email",
        "name_translations": { es: "Correo electrónico", en: "email" },
        "type": "text"
      },
      {
        "id": "birthdate",
        "name_translations": { es: "Fecha de nacimiento", en: "Birthdate" },
        "type": "date"
      },
      {
        "id": "weight",
        "name_translations": { es: "Peso", en: "Weight" },
        "type": "float"
      },
      {
        "id": "type",
        "name_translations": { es: "Tipo de empleado", en: "Type of employee" },
        "type": "vocabulary",
        "dataSource": "/admin/api/vocabularies/34"
      }
    ]
  }
}
```

## Installation

Previously you have to set `DEV_DIR` environment variable. Local gobierto application must be
under this path, i.e. the gobierto path must be `$DEV_DIR/gobierto`

Clone this repo and run `script/setup.sh`. It will create the following symbolic link in local
gobierto path: `$DEV_DIR/gobierto/vendor/gobierto_engines/custom-field-plugins-engine`.

## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
