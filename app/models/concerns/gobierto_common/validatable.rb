# frozen_string_literal: true

module GobiertoCommon
  module Validatable
    extend ActiveSupport::Concern

    included do
      def self.validated_attrs_for(validation)
        if validation.is_a?(String) || validation.is_a?(Symbol)
          klass = 'ActiveRecord::Validations::' \
                  "#{validation.to_s.camelize}Validator"
          validation = klass.constantize
        end
        self.validators
            .select { |v| v.is_a?(validation) }
            .map(&:attributes)
            .flatten
      end

      def self.get_maxlength(attribute)
        self.validators_on(attribute)
            .detect { |v| v.is_a?(ActiveModel::Validations::LengthValidator) }
            .options[:maximum]
      end
    end
  end
end
