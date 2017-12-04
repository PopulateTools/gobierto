![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

# Gobierto

## Developing a new module of Gobierto

> Date: 2017-03-15
> Author: Populate tools dev team
> Version: Draft

Gobierto modules implement well defined and isolated features of the application. Examples of modules are:

- Gobierto Budgets: municipalities budgets visualization.
- Gobierto Officials: senior officials official information and agenda publication.
- Gobierto Indicators: indicators and statics of a municipality.
- Gobierto CMS: small CMS system.
- Gobierto Participation: participation in phased processes.

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

When you create a module, you must define the root_path in config/routes.rb

```ruby
  # Gobierto People module
  namespace :gobierto_people, path: "/" do
    constraints GobiertoSiteConstraint.new do
      get "cargos-y-agendas" => "welcome#index", as: :root

```

Nowadays, we have 4 modules (Gobierto Budgets, Gobierto People, Gobierto Participation, Gobierto Indicators) that have root_path to be the home page.

```yml
default: &default
  site_modules_with_root_path:
    -
      name: Gobierto Budgets
      namespace: GobiertoBudgets
    -
      name: Gobierto People
      namespace: GobiertoPeople
    -
      name: Gobierto Participation
      namespace: GobiertoParticipation
    -
      name: Gobierto Indicators
      namespace: GobiertoIndicators
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

### Admin controllers

The new module might have admin actions. Declare these actions in controllers under `GobiertoAdmin` module. Each admin controller needs to be protected by two filters:

- `module_enabled!`: checks if the module is enabled in the site configuration
- `module_allowed!`: checks if the current admin has permissions on the current module

For example:

```ruby
before_action { module_enabled!(current_site, "GobiertoBudgetConsultations") }
before_action { module_allowed!(current_admin, "GobiertoBudgetConsultations") }
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

<%= render template: "layouts/application" %>
```

Also, you need to define a couple of files for the menus:

- `_navigation.main.html.erb`

- `_navigation.sub.html.erb`

### Admin menu

Create a new link adding the necessary permissions in `app/views/gobierto_admin/layouts/application.html.erb`. Example:

```ruby
# app/views/gobierto_admin/layouts/application.html.erb

<% if managing_site? %>
  <li>
    <%= link_to t('.edit_site'), edit_admin_site_path(current_site) %>
    <% if show_module_link?('GobiertoParticipation') %>
      <ul>
        <li><%= link_to t('.issues'), admin_issues_path %></li>
      </ul>
    <% end %>
  </li>
<% end %>

```

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

## Exports

GobiertoExports is a module that exposes a page where the user can download data in a reusable format (JSON and CSV). This page is composed by the exports exposed by each module. If your module wants to expose some exports in this page you need to add a folder named `exports` inside your module views folder with two partials:

- `_nav_item.html.erb` with the link to include in the module submenu, for example:

```ruby
<%= link_to t("gobierto_people.layouts.application.title"), gobierto_exports_root_path(anchor: 'section-people') %>
```

- `_index.html.erb` containing the html to include in the open data page, for example:

```ruby
<div class="pure-g data_block" id="section-people">

  <div class="pure-u-1 pure-u-md-7-24">
    <h2><%= t("gobierto_people.layouts.application.title") %></h2>
    <p></p>
  </div>

  <div class="pure-u-1 pure-u-md-17-24 main_content">

    <div class="data_item">
      <h3><%= t("gobierto_people.exports.index.people.title") %></h3>
      <%= link_to 'CSV', gobierto_people_people_path(format: :csv), class: 'button small' %>
      <%= link_to 'JSON', gobierto_people_people_path(format: :json), class: 'button small' %>
      <p><%= t("gobierto_people.exports.index.people.description") %></p>
    </div>

    <div class="data_item">
      <h3><%= t("gobierto_people.exports.index.events.title") %></h3>
      <%= link_to 'CSV', gobierto_people_events_path(format: :csv), class: 'button small' %>
      <%= link_to 'JSON', gobierto_people_events_path(format: :json), class: 'button small' %>
      <p><%= t("gobierto_people.exports.index.events.description") %></p>
    </div>

  </div>

</div>
```

Expose some endpoints in json and csv format, you can use a block like this

```ruby
respond_to do |format|
  format.html
  format.json { render json: @events }
  format.csv  { render csv: GobiertoExports::CSVRenderer.new(@events).to_csv, filename: 'events' }
end
```

For the json format put your module serializers into `app/serializers/<module_name>`.

For the csv define use the `GobiertoExports::CSVRenderer` with a relation and define two methods in the corresponding module, a class method named `csv_columns` that returns the csv headers and an instance method named `as_csv` that returns that record as an array of values to include in th csv.

Example:

```ruby
def self.csv_columns
  [:id, :name, :email, :charge, :bio, :bio_url, :avatar_url, :category, :political_group, :party, :created_at, :updated_at]
end

def as_csv
  political_group_name = political_group.try(:name)

  [id, name, email, charge, bio, bio_url, avatar_url, category, political_group_name, party, created_at, updated_at]
end
```

## Activities

Gobierto has an activities log that save the admin events in the application. For example, to save this
information we must generate into `app/pub_sub/` the publisher and the subscriber to events like
created page, updated page or deleted page.

```ruby
module Publishers
  class GobiertoCmsPageActivity
    include Publisher

    self.pub_sub_namespace = 'activities/gobierto_cms_pages'
  end
end
```

```ruby
module Subscribers
  class GobiertoCmsPageActivity < ::Subscribers::Base
    def page_created(event)
      create_activity_from_event(event, 'gobierto_cms.page_created')
    end

    def page_updated(event)
      create_activity_from_event(event, 'gobierto_cms.page_updated')
    end

    def page_deleted(event)
      create_activity_from_event(event, 'gobierto_cms.page_deleted')
    end

    private

    def create_activity_from_event(event, action)
      Activity.create! subject: event.payload[:subject],
                       author: event.payload[:author],
                       subject_ip: event.payload[:ip],
                       action: action,
                       site_id: event.payload[:site_id],
                       admin_activity: true
    end
  end
end
```

These events have to be called from the controller with **track_create_activity**:

```ruby
# app/controllers/gobierto_admin/gobierto_participation/issues_controller.rb

module GobiertoAdmin
  module GobiertoParticipation
    class IssuesController < BaseController

      ...

      def create
        @issue_form = IssueForm.new(issue_params.merge(site_id: current_site.id))

        if @issue_form.save
          track_create_activity

          redirect_to(
            admin_issues_path(@issue),
            notice: t(".success")
          )
        else
          render :new_modal, layout: false and return if request.xhr?
          render :new
        end
      end

      ...

      private

      def track_create_activity
        Publishers::GobiertoParticipationIssueActivity.broadcast_event("issues.issue_created", default_activity_params.merge({subject: @issue_form.issue}))
      end
      ...
    end
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
