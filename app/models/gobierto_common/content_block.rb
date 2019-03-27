# frozen_string_literal: true

module GobiertoCommon
  class ContentBlock < ApplicationRecord
    belongs_to :site

    has_many :fields, dependent: :destroy, class_name: "ContentBlockField"
    has_many :records, dependent: :destroy, class_name: "ContentBlockRecord"

    cattr_accessor :content_context

    scope :sorted, -> { order(id: :asc) }

    def self.set_content_context(content_context)
      tap do |content_block_class|
        content_block_class.content_context = content_context
      end
    end

    def records
      if self.class.content_context.present?
        return super.where(content_context: self.class.content_context)
      end

      super
    end

    def localized_title
      title[I18n.locale.to_s]
    end
  end
end
