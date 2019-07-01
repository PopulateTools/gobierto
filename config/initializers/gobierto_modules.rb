# frozen_string_literal: true

SITE_MODULES.each do |gobierto_module|
  file_name = gobierto_module.underscore
  file_path = Rails.root.join("app/models/#{file_name}.rb")
  require_dependency(file_name) if File.file?(file_path)
end

Rails.application.config.plugins_attached_modules.each do |class_name, modules_classes|
  modules_classes.each { |module_class| Object.const_get(class_name).prepend(module_class) }
end
