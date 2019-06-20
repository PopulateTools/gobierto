# frozen_string_literal: true

module GobiertoCommon
  class CustomFieldPlugin

    attr_accessor :type

    def initialize(type, params = {})
      self.type = type
      @requires_vocabulary = params[:requires_vocabulary] || false
    end

    def requires_vocabulary?
      @requires_vocabulary
    end

    def self.all
      Rails.application.config.custom_field_plugins.map do |key, value|
        CustomFieldPlugin.new(key, value)
      end
    end

    def self.find(type)
      return unless type

      all.find do |plugin|
        plugin.type == type.to_sym
      end
    end

  end
end
