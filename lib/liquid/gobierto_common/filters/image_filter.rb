# frozen_string_literal: true

require "liquid"

module ImageFilter
  def image_url(input)
    ActionController::Base.helpers.image_url(input)
  end
end

Liquid::Template.register_filter(ImageFilter)
