# frozen_string_literal: true

module GobiertoCommon
  class CustomFieldPlugin

    attr_accessor :type, :default_configuration

    attr_reader :callbacks, :position

    def initialize(type, params = {})
      self.type = type
      @requires_vocabulary = params[:requires_vocabulary] || false
      @has_configuration = params[:has_configuration] || false
      @default_configuration = params[:default_configuration]
      @callbacks = params[:callbacks] || []
      @position = params[:position] || 999
    end

    def requires_vocabulary?
      @requires_vocabulary
    end

    def has_configuration?
      @has_configuration
    end

    def has_callbacks?
      @callbacks.present?
    end

    def self.all
      Rails.application.config.custom_field_plugins.map do |key, value|
        CustomFieldPlugin.new(key, value)
      end
    end

    def self.all_sorted
      all.sort_by(&:position)
    end

    def self.with_callbacks
      all.select(&:has_callbacks?)
    end

    def self.find(type)
      return unless type

      all.find do |plugin|
        plugin.type == type.to_sym
      end
    end

  end
end
