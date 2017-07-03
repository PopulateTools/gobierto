module GobiertoCommon
  class CollectionItem < ApplicationRecord
    belongs_to :site
    belongs_to :item, polymorphic: true
    belongs_to :container, polymorphic: true

    def container
      if container_id.present?
        super
      else
        container_type.constantize
      end
    end
  end
end
