# frozen_string_literal: true

module LiquidHelper
  def render_liquid(template_content)
    template_content = template_content.gsub(/<%.*%>/, "")
    template = Liquid::Template.parse(template_content)
    template.assigns["current_site"] = current_site
    template.render.html_safe
  end
end
