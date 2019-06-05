# frozen_string_literal: true

module GobiertoAdmin
  class BaseResourceDecorator < BaseDecorator
    def initialize(resource, _opts = {})
      @object = resource
    end

    def name
      @name ||= try(:name) || try(:title) || to_s
    end

    def model_param
      @object.class.name.underscore.tr("/", "-")
    end

    def resource_model_name(count: 1)
      @resource_model_name ||= model_name.human(count: count)
    end
  end
end
