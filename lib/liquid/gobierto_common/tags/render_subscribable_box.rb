# frozen_string_literal: true

include User::SessionHelper

class RenderSubscribableBox < Liquid::Tag
  def initialize(tag_name, params, tokens)
    super
  end

  def render(context)
    renderer = ApplicationController.renderer.new(method: 'post', https: true)
    renderer.render partial: 'user/subscriptions/subscribable_box', locals: { subscribable: context.environments.first['current_site'], title: I18n.t("gobierto_people.people.index.subscribable_box.title") }
  end
end

Liquid::Template.register_tag("render_subscribable_box", RenderSubscribableBox)
