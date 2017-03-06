![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

# Gobierto

## Developing a new module of Gobierto

> Date: 2017-01-26
> Author: Populate tools dev team
> Version: Draft

Gobierto modules implement well defined and isolated features of the application. Examples of modules are:

- Gobierto Budgets: municipalities budgets visualization
- Gobierto Officials: senior officials official information and agenda publication
- Gobierto Indicators: indicators and statics of a municipality
- Gobierto CMS: small CMS system

Modules can be activated or disabled by the **metadministrator**, but their code will be included in all the installations of Gobierto.

This page describes the steps needed to create a new module and integrate it in the application.

## Module basic attributes

Every module has a name and defines a namespace. These attributes are defined in `config/application.yml`:

```yml
default: &default
  site_modules:
    -
      name: Gobierto Development
      namespace: GobiertoDevelopment
    -
      name: Gobierto Budgets
      namespace: GobiertoBudgets
```

This namespace is applied to models, assets, helpers, controllers, views, I18n keys, tests, and the routes. This guide covers the steps you need to follow on each of those resources to enable the new module.

If the module needs special configuration, create an entry in the `application.yml` file with the name of the module:

```yml
  gobierto_budgets:
    data_note_url: https://presupuestos.gobierto.es/about#method
  gobierto_people:
    gifts_service_url: <%= ENV["PEOPLE_GIFTS_SERVICE_URL"] %>
    travels_service_url: <%= ENV["PEOPLE_TRAVELS_SERVICE_URL"] %>
```

## Models

If your module implements models, create a folder to store them with the module name, and remember to declare the class under the Ruby module name.

For example:

```ruby
# app/models/gobierto_people/person.rb

require_dependency "gobierto_people"

module GobiertoPeople
  class Person < ApplicationRecord
    include ::GobiertoCommon::DynamicContent
    include User::Subscribable
...
```

In case your model implements a relationship with other model outside the module, you shouldn't include the module name in the name of the relationship for readability reasons, unless there is a name conflict.

Example:

```ruby
# preferred way
class User < AppplicationRecord
   has_many :posts, class_name: 'GobiertoPublications::Post'
end
```

vs.

```ruby
# we don't like this
class User < AppplicationRecord
   has_many :gobierto_publications_posts
end
```

Define a table name prefix for your module in `app/models/<name of your module>`. For example:

```ruby
# app/models/gobierto_people.rb

module GobiertoPeople
  def self.table_name_prefix
    'gp_'
  end
end
```

If you create unit tests, define them in a folder with the module name, i.e. `test/models/gobierto_people/person_test.rb`

## Controllers

Declare your controllers in a specific folder for the module, and declare your classes under the Ruby module namespace.

Also, declare an `ApplicationController` inside the new module, to define the layout.

For example:

```ruby
# app/controllers/gobierto_people/application_controller.rb

module GobiertoPeople
  class ApplicationController < ::ApplicationController
    include User::SessionHelper

    layout "gobierto_people/layouts/application"
  end
end
```

## Views

Declare your views in a specific folder for the module. Include a layouts folder to define the module layout. Use the nested layout syntax of Rails.

At least include:

1. The javascript application file of your module
2. Custom breadcrumb items
3. A render to the main layout

```ruby
# app/views/gobierto_people/layouts/application.html.erb

<% content_for :javascript_include do %>
  <%= javascript_include_tag 'gobierto_people/application', 'data-turbolinks-track' => true %>
<% end %>

<% content_for :breadcrumb_items do %>
  <strong>
    <%= link_to t('gobierto_people.layouts.application.title'), gobierto_people_root_path %>
  </strong>
  <% if content_for?(:breadcrumb_current_item) %>
    <span>/</span>
    <%= yield(:breadcrumb_current_item) %>
  <% end %>
<% end %>

<%= render template: "layouts/application" %>
```

Also, you need to define a couple of files for the menus:

- `_menu_subsections.html.erb`

- `_navigation.html.erb`


## Routes

Module routes must be declared under a namespace specific for the module. Example:

```ruby
namespace :gobierto_budgets, path: '', module: 'gobierto_budgets' do
  constraints GobiertoSiteConstraint.new do
    get 'site' => 'sites#show'
    ...
  end
end
```


## Assets

### Stylesheets

Declare a file `module-<name of your module>.scss` in the Rails folder `app/assets/stylesheets`.

### Javascripts

Create a specific folder for your module, and create an `application.js` file. If the module needs vendor libraries add them to `vendor/assets/javascripts`.


## I18n keys

Declare a folder for the module in `config/locales/`, but only **controllers** and **views** can be defined on it. **Models** and **routes** must be defined outside the module (this is because how Rails uses the namespace of I18n).


## Migrations

In case your module needs migrations, every migration you define needs to be preffixed with the namespace. Example:

```
rails g migration gobierto_budgets_add_budget_line_description
```


## Tests

There are many type of tests, just create a subfolder with the name of the module depending on the type of test.


## Admin permissions

In `app/models/gobierto_admin/permission/` a subclass of `Admin::Permission` will be implemented, defining a scope, which will limit the access.

Example:

```ruby
module GobiertoAdmin
  class Permission::GobiertoBudgetConsultations < Permission
    default_scope -> do
      where(namespace: "site_module", resource_name: "gobierto_budget_consultations")
    end
  end
end
```

## Seeds

Sometimes modules need some database data to exist. For example, a configuration entry, a list of `DynamicContentBlocks` preconfigured. For that reason, we have created a seeds structure and two seeds runner classes:

- `ModuleSeeder`: seeds a module
- `ModuleSiteSeeder`: seeds a module for a specific Gobierto installation. It uses the attribute `site.name` from `config/application.yml`

Both seed types can be found in `db/seeds/modules` and `db/seeds/sites`.

These seeds are executed when a module is **activated** in a site. De-activating the module doesn't run the seeder. Keep this in mind in order to write idempotent scripts.

Here's a template of the seed class:

```ruby
module GobiertoSeeds
  class Recipe
    def self.run(site)
      # Your code goes here
    end
  end
end
```
