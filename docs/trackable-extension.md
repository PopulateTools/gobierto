![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

# Gobierto (dev)

## Integrating the Trackable extension

> Date: 2016-12-20  
> Author: Populate tools dev team  
> Version: Draft

### Concept

The `GobiertoCommon::Trackable` module extends the current Form class by
providing a way to track changes in a specific resource, which can
correspond to a well-known `ActiveRecord` model.

*Note: This is still under development.*

### Implementation

An implementation sample can be found at
[`GobiertoAdmin::GobiertoBudgetConsultations::ConsultationForm`](https://github.com/PopulateTools/gobierto-dev/blob/5c4efc0870b7bc830d2b4869289ddb854a723d12/app/forms/gobierto_admin/gobierto_budget_consultations/consultation_form.rb). There are just a few sections to highlight:

First of all, the `GobiertoCommon::Trackable` extension must be loaded
by prepending the module in the corresponding class. e.g.:

```ruby
module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationForm
      ...

      prepend GobiertoCommon::Trackable
    end
  end
end
```

After having loaded the extension, its behavior can be configured
through a quite simple DSL. We would need to specify which will
be the main resource to watch (it should correspond to a `ActiveRecord`
model for now) to produce the notification events. In this case, we're
delegating it in the `consultation` method, as follows:

```ruby
trackable_on :consultation
```

It also provides syntax to limit the attributes that are going to be
tracked. In this case, only changes in `title`, `visibility_level`,
`opens_on` and `closes_on` attributes will be notified:

```ruby
notify_changed :title
notify_changed :visibility_level
notify_changed :opens_on
notify_changed :closes_on
...
```

To let the extension track those changes, it is also required to wrap
the saving action within a `run_callbacks(:save)` block since it makes
use of the [`ActiveModel::Dirty`](http://api.rubyonrails.org/classes/ActiveModel/Dirty.html)
feature. The model's callbacks are already defined so this is the only
needed change:

```ruby
run_callbacks(:save) do
  @consultation.save
end
```

Finally, there is a method that can be defined at class level to limit
notifications based on its own business logic. It is not required so the
notification will be performed if no `notify?` method is defined. e.g.:

```ruby
def notify?
  consultation.active?
end
```
