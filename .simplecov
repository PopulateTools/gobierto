# frozen_string_literal: true

if ENV["CI"]
  SimpleCov.start "rails" do
    add_filter "/config/"
    add_filter "/db/"
    add_filter "/test/"
    add_filter "/docs/"
    add_filter "/node_modules/"
    add_filter "/log/"
    add_filter "/public/"
    add_filter "/script/"
    add_filter "/bin/"

    add_group "Cells", "app/cells"
    add_group "Controllers", "app/controllers"
    add_group "Decorators", "app/decorators"
    add_group "Extensions", "app/extensions"
    add_group "Forms", "app/forms"
    add_group "Helpers", "app/helpers"
    add_group "Importers", "app/importers"
    add_group "Jobs", "app/jobs"
    add_group "Mailers", "app/mailers"
    add_group "Models", "app/models"
    add_group "Policies", "app/policies"
    add_group "Presenters", "app/presenters"
    add_group "PubSub", "app/pub_sub"
    add_group "Queries", "app/queries"
    add_group "Repositories", "app/repositories"
    add_group "Serializers", "app/serializers"
    add_group "Services", "app/services"
    add_group "Views", "app/views"
  end

  SimpleCov.merge_timeout 1800
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end
