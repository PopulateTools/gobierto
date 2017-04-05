module GobiertoAdmin
  module FormHelper
    def self.included(base)
      ActionView::Helpers::FormBuilder.instance_eval do
        include FormBuilderMethods
      end
    end

    def rich_text_area_tag(method, value, options = {})
      content_tag(:div, class: "rich-text-area", id: "#{method}_rich") do
        [
          hidden_field_tag(method, value),
          content_tag(
            "trix-editor",
            nil,
            input: sanitize_to_id(method),
            data: { attachment_path: options[:attachment_path] }
          ),
          content_tag(
            "div",
            content_tag("i", nil, class: "fa fa-info") +
              I18n.t("gobierto_admin.form_helpers.rich_text_area.hints"),
            class: "inline_help"
          )
        ].join.html_safe
      end
    end
  end

  module FormBuilderMethods
    def rich_text_area(method, options = {})
      @template.content_tag(:div, class: "rich-text-area", id: "#{@object_name}_#{method}_rich") do
        [
          @template.hidden_field(@object_name, method),
          @template.content_tag(
            "trix-editor",
            nil,
            input: "#{@object_name}_#{method}",
            data: { attachment_path: options[:attachment_path] }
          ),
          @template.content_tag(
            "div",
            @template.content_tag("i", nil, class: "fa fa-info") +
              I18n.t("gobierto_admin.form_helpers.rich_text_area.hints"),
            class: "inline_help"
          )
        ].join.html_safe
      end
    end
  end
end
