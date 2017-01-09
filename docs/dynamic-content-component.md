![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

# Gobierto

## Integrating the DynamicContent component

> Date: 2016-12-26  
> Author: Populate tools dev team  
> Version: Draft

### Concept

The `DynamicContent` component consists on a base feature that allows
managing schema free content blocks, and a collection of helpers which
significantly ease the integration process.

*Note: This is still under development.*

### Implementation

A good integration sample can be found in the `GobiertoPeople::Person`
implementation. Anyways, in order to make things clearer, we would like
to recap the steps to follow:

#### Setting up the model associations

It is only required to import a Model concern in any subclass of
`ApplicationRecord`, which is available via:

```ruby
include ::GobiertoCommon::DynamicContent
```

#### Processing Content Block records at Form object level

There is also a Helper module that can be just included in any of our
`Form` classes, like this:

```ruby
include ::GobiertoCommon::DynamicContentFormHelper
```

After having included the Helper module, the resource accessor method
(e.g. `person`) must be aliased to `content_context` to let the Helper
manage its Content Blocks for us:

```ruby
def person
  @person ||= ...
end
alias content_context person
```

Finally, the result of processing and/or building a collection of Content
Block Records can be retrieved through the `content_block_records`
method, so there is only need to set the corresponding attribute on a
saving action:

```ruby
def save_person
  @person = person.tap do |person_attributes|
    ...
    person_attributes.content_block_records = content_block_records
  end
end
```

#### Permitting parameters through the Controller Helper

A set of parameters that must be permitted through the
[Strong Parameters](http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters)
feature is available at `dynamic_content_attributes`, right after
including the corresponding Helper at Controller level:

```ruby
include ::GobiertoCommon::DynamicContentHelper
```

```ruby
def resource_params
  params.require(:resource_name).permit(
    :resource_param,
    ...
    dynamic_content_attributes
  )
end
```

#### Rendering the dynamic content form

In order to expose the Dynamic content management form in the UI, there
is a form builder that can be rendered within this partial view:

```erb
<%= render "gobierto_admin/gobierto_common/dynamic_content/form", form_builder: f %>
```

#### Testing support

Last but not least, there are a couple of helper methods that could be
included in our Integration test cases to avoid repeating ourselves:

```ruby
require "support/integration/dynamic_content_helpers"

include Integration::DynamicContentHelpers
```

Those helper methods are:

```ruby
fill_in_content_blocks
```

```ruby
assert_content_blocks_have_the_right_values
```

The `fill_in_content_blocks` method pre-fills any Dynamic
Content-related fields as a preparatory step to make the
final assertions in `assert_content_blocks_have_the_right_values`.

There is also a helper method that can be used to check every single
action regarding Content block record management:
`assert_content_blocks_can_be_managed`.
