# frozen_string_literal: true

if ENV["CI"]
  SimpleCov.start "rails" do
    ## add_filter "app/models/concerns"
    ## add_filter "app/controllers/concerns"
    add_filter "/config/"
    add_filter "/db/"
    add_filter "/test/"

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

  ##   # `ENGINE_ROOT` holds the name of the engine we're testing.
  ##   # This brings us to the main Decidim folder.
  ##   root File.expand_path("..", ENV["ENGINE_ROOT"])

  ##   # We make sure we track all Ruby files, to avoid skipping unrequired files
  ##   # We need to include the `../` section, otherwise it only tracks files from the
  ##   # `ENGINE_ROOT` folder for some reason.
  ##   track_files "../**/*.rb"

  ##   # We ignore some of the files because they are never tested
  ##   add_filter %r{^/decidim-[^/]*/lib/decidim/[^/]*/engine.rb}
  ##   add_filter %r{^/decidim-[^/]*/lib/decidim/[^/]*/admin-engine.rb}
  ##   add_filter %r{^/decidim-[^/]*/lib/decidim/[^/]*/component.rb}
  ##   add_filter %r{^/decidim-[^/]*/lib/decidim/[^/]*/participatory_space.rb}
  ## end

  SimpleCov.merge_timeout 1800
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
