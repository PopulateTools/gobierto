# frozen_string_literal: true

SITE_MODULES.each do |gobierto_module|
  file_name = gobierto_module.underscore
  file_path = Rails.root.join("app/models/#{file_name}.rb")
  require_dependency(file_name) if File.file?(file_path)
end
