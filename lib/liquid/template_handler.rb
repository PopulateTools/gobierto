module Liquid
  module Rails
    class TemplateHandler

      include ActionView::Helpers::SanitizeHelper

      def render(template, local_assigns={})
        assigns = if @controller.respond_to?(:liquid_assigns, true)
          @controller.send(:liquid_assigns)
        else
          @view.assigns
        end
        # If there's content for content block render it first, otherwise, render the layout
        if @view.content_for?(:content)
          assigns['content_for_layout'] = @view.content_for(:content)
        elsif @view.content_for?(:layout)
          assigns['content_for_layout'] = @view.content_for(:layout)
        end
        assigns.merge!(local_assigns.stringify_keys)

        liquid = Liquid::Template.parse(template)
        liquid.send(render_method, assigns, filters: filters, registers: registers).html_safe
      end

    end
  end
end
