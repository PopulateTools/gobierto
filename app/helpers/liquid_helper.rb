# frozen_string_literal: true

module LiquidHelper
  def render_liquid(template_content)
    liquid_str = GobiertoCore::SiteTemplate.liquid_str(current_site, template_content)

    if liquid_str
      template_content = liquid_str
    end

    template = to_liquid(template_content)
    sanitize template.render
  end

  def to_liquid(template_content)
    template_content = template_content.gsub(/<%.*%>/, "")
    template = Liquid::Template.parse(template_content)
    template.assigns["current_site"] = current_site
    template
  end
end
