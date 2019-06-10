# Custom Fields Plugins Engine

The purpose of this engine is to define new plugins or override existing ones, used by custom fields of this type.

## Usage


* Declare the available plugins in the railtie adding their names to the list of `custom_field_plugins`, for example, a `test` type:

```ruby
  Rails.application.config.tap do |conf|
    conf.custom_field_plugins += ["test"]
  end
```

The `test` type will be available in the options of plugin custom field type

* Define the translations of the `test` plugin type in `config/locales` for `gobierto_admin.gobierto_common.custom_fields.plugin.test`

* In the admin form of an instance with custom field recors of `test` type a `form()` javascript method will be expected with the name:

```
  window.GobiertoAdmin.gobierto_common_custom_field_records_test_plugin_controller.form({ uid: record_uid })
```

The argument received by this method will be an object containing at least the uid of the custom field record.

The payload of the field can be accessed and changed in the hidden field:

```
<input type="hidden" name="instance_name[custom_records][record_uid][value]" id="instance_name_custom_records_record_uid_value" value="..." />
```

`instance_name` changes depending on the item the record belongs to (project, citizen_charter, person...) and the record_uid is given by the record

The javascript is responsible to read, manipulate and change the value. When the form is sent, the value of the hidden field will be saved in the corresponding record.

## Installation
Previously you have to set `DEV_DIR` environment variable. Local gobierto application must be
under this path, i.e. the gobierto path must be `$DEV_DIR/gobierto`

Clone this repo and run `script/setup.sh`. It will create the following symbolic link in local
gobierto path: `$DEV_DIR/gobierto/vendor/gobierto_engines/custom-field-plugins-engine`.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

