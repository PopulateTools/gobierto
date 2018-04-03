# frozen_string_literal: true

class BodyCssClasses < Liquid::Tag
  def render(context)
    context.registers[:view].body_css_classes
  end
end

Liquid::Template.register_tag("body_css_classes", BodyCssClasses)
