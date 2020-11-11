# frozen_string_literal: true

module Liquid
  module GobiertoCommon
    module Tags
      class BodyCssClasses < Liquid::Tag
        def render(context)
          context.registers[:view].body_css_classes
        end
      end
    end
  end
end

Liquid::Template.register_tag("body_css_classes", Liquid::GobiertoCommon::Tags::BodyCssClasses)
