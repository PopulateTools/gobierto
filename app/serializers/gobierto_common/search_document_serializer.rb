# frozen_string_literal: true

module GobiertoCommon
  class SearchDocumentSerializer < ActiveModel::Serializer

    attribute :title_translations, if: :with_translations?
    attribute :description_translations, if: :with_translations?
    attribute :title, unless: :with_translations?
    attribute :description, unless: :with_translations?

    attributes(
      :searchable_type,
      :searchable_id,
      :resource_path,
      :meta,
      :updated_at
    )

    def with_translations?
      instance_options[:with_translations]
    end
  end
end
