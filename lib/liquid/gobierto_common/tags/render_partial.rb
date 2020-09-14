# frozen_string_literal: true

module Liquid
  module GobiertoCommon
    module Tags
      class RenderPartial < Liquid::Tag
        def initialize(tag_name, partial_name, options)
          super
          @partial_name = partial_name.gsub(/\s|"|'/, "").strip
        end

        def render(context)
          context.registers[:view].dup.render(partial: @partial_name)
        end
      end
    end
  end
end

Liquid::Template.register_tag("render_partial", Liquid::GobiertoCommon::Tags::RenderPartial)
