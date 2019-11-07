# frozen_string_literal: true

class GobiertoModuleGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  class_option :title, type: :string, desc: "String to identify the module. If not present TITLE will be inferred with titleize inflection from module class name"
  class_option :fron_path, type: :string, desc: "String for the base path of module in front. If not present FRONT_PATH will be inferred with parameterize inflection from TITLE"
  class_option :table_prefix, type: :string, desc: "Table prefix. It not present it will be inferred from module name. For example: 'gobierto_test' will generate 'gtest_'"

  attr_reader :module_name, :module_class_name, :module_title, :module_front_path, :table_prefix
  def initialize_names
    @module_class_name = name
    @module_name = name.underscore
    @module_title = options["title"] || name.titleize
    @module_front_path = (options["front_path"] || module_title).parameterize
    @table_prefix = options["table_prefix"] || module_name.gsub(/^gobierto_/, "g")[0, 5]
    @table_prefix = "#{@table_prefix}_" if @table_prefix.last != "_"
  end

  def insert_into_application_site_modules
    inject_into_file "config/application.yml", before: "  site_modules_with_root_path:\n" do
      <<-YAML
    -
      name: #{module_title}
      namespace: #{module_class_name}
      YAML
    end
  end

  def add_root_path
    inject_into_file "config/routes.rb", before: "    # Add new modules before this line" do
      <<-RUBY
    # #{module_title} module
    namespace :#{module_name}, path: "#{module_front_path}" do
      constraints GobiertoSiteConstraint.new do
        get "/" => "welcome#index", as: :root
      end
    end

      RUBY
    end
  end

  def create_lib_file
    template("models/module_model.rb.tt", "app/models/#{module_name}.rb")
  end

  def create_controllers
    template("controllers/application_controller.rb.tt", "app/controllers/#{module_name}/application_controller.rb")
    template("controllers/welcome_controller.rb.tt", "app/controllers/#{module_name}/welcome_controller.rb")
  end

  def create_layout_and_views
    template("views/layouts/_navigation.main.html.erb.tt", "app/views/#{module_name}/layouts/_navigation.main.html.erb")
    template("views/layouts/application.html.erb.tt", "app/views/#{module_name}/layouts/application.html.erb")
    template("views/welcome/index.html.erb.tt", "app/views/#{module_name}/welcome/index.html.erb")
  end

  def create_locale_files
    template("locales/views/ca.yml.tt", "config/locales/#{module_name}/views/ca.yml")
    template("locales/views/en.yml.tt", "config/locales/#{module_name}/views/en.yml")
    template("locales/views/es.yml.tt", "config/locales/#{module_name}/views/es.yml")
  end
end
