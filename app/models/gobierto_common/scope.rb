module GobiertoCommon
  class Scope < ApplicationRecord
    include GobiertoCommon::Sortable
    
    translates :name, :description

    belongs_to :site
    has_many :processes, class_name: 'GobiertoParticipation::Process', dependent: :restrict_with_error

    validates :site, presence: true

    scope :sorted, -> { order(position: :asc, created_at: :desc) }
  end
end