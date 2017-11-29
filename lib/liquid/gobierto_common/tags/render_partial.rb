# frozen_string_literal: true

class RenderPartial < Liquid::Tag
  def initialize(tag_name, partial_name, options)
    super
    @partial_name = partial_name.gsub(/\s|"|'/, "")
  end

  def render(context)
    context.registers[:controller].dup.render(partial: @partial_name.strip)
  end
end

Liquid::Template.register_tag("render_partial", RenderPartial)
