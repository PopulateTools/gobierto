# frozen_string_literal: true

include ApplicationHelper
include User::SessionHelper

class RenderPartial < Liquid::Tag
  def initialize(tag_name, partial_name, options)
    super
    @partial_name = partial_name.gsub(/\s|"|'/, "").strip
  end

  def render(context)
    if context.registers[:controller]
      context.registers[:controller].dup.render(partial: @partial_name)
    else
      # renderer = ApplicationController.renderer.new(method: 'post', https: true)
      # #renderer.instance_variable_set(:@site, context.environments.first['current_site'])
      # byebug
      # renderer.render(partial: @partial_name, current_site: context.environments.first['current_site']).squish
      # renderer.render(partial: @partial_name, assings: { current_site: context.environments.first['current_site']}).squish
      # renderer.render(partial: @partial_name, locals: { current_site: context.environments.first['current_site']}).squish

      ApplicationController.render(
        partial: @partial_name,
        assigns: {
          current_site: context.environments.first['current_site']
        }
      )
    end
  end
end

Liquid::Template.register_tag("render_partial", RenderPartial)
