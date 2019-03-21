# frozen_string_literal: true

module GobiertoCore
  module DecoratorsHelper
    def render_decorator_template(decorator_or_resource, template, options = {})
      format = options.delete(:format) || "html.erb"
      decorator = decorator_or_resource.try(:decorator) || decorator_or_resource
      decorator_path = decorator.name.underscore
      template_name = decorator.try(template)
      return if template_name.blank?

      partial_path = File.join("shared/decorators/", decorator_path, "_#{template_name}.#{format}")

      return unless lookup_context.exists? partial_path

      render(File.join("shared/decorators/", decorator_path, template_name), options)
    end
  end
end
