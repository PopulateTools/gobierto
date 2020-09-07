# frozen_string_literal: true

require "liquid"
module Liquid
  module GobiertoCommon
    module Filters
      module ImageFilter
        def image_url(input)
          ActionController::Base.helpers.image_url(input)
        end
      end
    end
  end
end

Liquid::Template.register_filter(Liquid::GobiertoCommon::Filters::ImageFilter)
