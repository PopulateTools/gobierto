# frozen_string_literal: true

Rails.application.config.plugins_attached_modules.each do |class_name, modules_classes|
  modules_classes.each { |module_class| Object.const_get(class_name).prepend(module_class.constantize) }
end
