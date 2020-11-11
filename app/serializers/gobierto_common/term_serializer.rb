# frozen_string_literal: true

module GobiertoCommon
  class TermSerializer < ActiveModel::Serializer

    attribute :name_translations, if: :with_translations?
    attribute :description_translations, if: :with_translations?
    attribute :name, unless: :with_translations?
    attribute :description, unless: :with_translations?

    attributes(
      :id,
      :slug,
      :position,
      :level,
      :term_id
    )

    def with_translations?
      instance_options[:with_translations]
    end
  end
end
