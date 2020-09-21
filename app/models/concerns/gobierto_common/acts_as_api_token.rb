# frozen_string_literal: true

module GobiertoCommon
  module ActsAsApiToken
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_api_token_on(name, **opts)
        singularized_name = name.to_s.singularize.to_sym

        belongs_to singularized_name, **opts.slice(:class_name, :foreign_key)
        has_secure_token
        validates singularized_name, presence: true
        validates :name, uniqueness: { scope: singularized_name }, unless: :blank_name?
        validates singularized_name, uniqueness: { scope: :primary }, if: :primary?
        validates :domain, domain: true

        scope :primary, -> { where(primary: true) }
        scope :secondary, -> { where(primary: false) }
      end
    end

    def to_s
      token
    end

    def blank_name?
      name.blank?
    end

  end
end
