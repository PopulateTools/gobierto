# frozen_string_literal: true

module GobiertoCommon
  module Metadatable
    extend ActiveSupport::Concern

    included do

      def self.metadata_attributes(*attributes)
        attributes.map(&:to_sym).each do |attribute|
          define_method(attribute) { meta[attribute.to_s] if meta }
        end
      end

    end

  end
end
