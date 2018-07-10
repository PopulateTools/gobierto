# frozen_string_literal: true

module GobiertoCommon
  module AttributeLengthValidatable
    extend ActiveSupport::Concern

    included do
      def self.max_length(attribute)
        length_validators = validators_on(attribute).select do |v|
          [ActiveModel::Validations::LengthValidator, TranslatedAttributeLengthValidator].include?(v.class)
        end
        length_validators.map { |v| v.options[:maximum] }.max
      end
    end

  end
end
