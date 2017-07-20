module GobiertoCommon
  class CollectionItem < ApplicationRecord
    belongs_to :collection
    belongs_to :item, polymorphic: true
    belongs_to :container, polymorphic: true

    def container
      if container_id.present?
        super
      end
    end
  end
end
