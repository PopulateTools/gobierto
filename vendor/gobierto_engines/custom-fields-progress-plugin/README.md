# Progress Custom Field Plugin Engine

The purpose of this engine is to define a plugin to calculate progress. The progress is
calculated based on other custom fields for the same item.

## Usage

* Install the plugin.
* Define a plugin custom field of type "Progress".
* A text area for options will appear. Use this section to define which custom fields defined
on the same element should be used to calculate the progress. The custom fields can be called
by their id or uid. Example:

```json
{
  "custom_field_ids": [
    ...
  ],
  "custom_field_uids": [
    ...
  ]
}
```

* The plugin sets a list of callback functions to be called when one of the custom field records
dependent to the related custom fields defined in the previous step is saved. In this case the
plugin callback recalculates the progress of the item.
* The engine provides a task to recalculate all the progresses. Just run
`rake gobierto_admin:calculate_progress` from gobierto application.
* The javascript for the plugin displays the progress in percentage in a text input disabled.
This field is read only and can't be changed in the custom fields form.

## Installation

Previously you have to set `DEV_DIR` environment variable. Local gobierto application must be
under this path, i.e. the gobierto path must be `$DEV_DIR/gobierto`

Clone this repo and run `script/setup.sh`. It will create the following symbolic link in local
gobierto path: `$DEV_DIR/gobierto/vendor/gobierto_engines/custom-field-plugins-engine`.

## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
