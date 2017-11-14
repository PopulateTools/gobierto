# frozen_string_literal: true

module GobiertoCommon
  class CollectionItem < ApplicationRecord
    belongs_to :collection
    belongs_to :item, polymorphic: true
    belongs_to :container, polymorphic: true

    after_commit :reindex_page

    def container
      if container_id.present?
        super
      end
    end

    private

    def reindex_page
      if item.class_name == "GobiertoCms::Page"
        ::GobiertoCms::Page.trigger_reindex_job(item, false)
      end
    end
  end
end
