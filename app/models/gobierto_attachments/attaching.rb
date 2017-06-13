require_dependency 'gobierto_people'

module GobiertoAttachments
  class Attaching < ApplicationRecord

    belongs_to :site
    belongs_to :attachment
    belongs_to :attachable, polymorphic: true

    validates :site, :attachment, :attachable, presence: true

  end
end
