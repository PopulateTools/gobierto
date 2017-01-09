module GobiertoAdmin
  module FormHelper
    def self.included(base)
      ActionView::Helpers::FormBuilder.instance_eval do
        include FormBuilderMethods
      end
    end
  end

  module FormBuilderMethods
    def rich_text_area(method, options = {})
      @template.content_tag(:div, class: "rich-text-area", id: "#{@object_name}_#{method}_rich") do
        @template.hidden_field(@object_name, method) +
          @template.content_tag(
            "trix-editor",
            nil,
            input: "#{@object_name}_#{method}",
            data: { attachment_path: options[:attachment_path] }
          )
      end
    end
  end
end
