require_dependency "gobierto_participation"

module GobiertoParticipation
  class ProcessStage < ApplicationRecord

    attr_accessor(:active)

    belongs_to :process

    translates :title, :description

    enum stage_type: [ :information, :meetings, :surveys, :ideas, :results ]

    validates :slug, uniqueness: { scope: [:process_id] }
    validates :title, :stage_type, presence: true
    validates :stage_type, inclusion: { in: stage_types }
    validates :stage_type, uniqueness: { scope: [:process_id] }
    validates :starts, :ends, presence: true, if: -> { process.process? }

    scope :sorted, -> { order(id: :desc) }

  end
end
