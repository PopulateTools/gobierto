require_dependency "gobierto_participation"

module GobiertoParticipation
  class ProcessStage < ApplicationRecord

    belongs_to :process

    translates :title, :description

    enum stage_type: { information: 0, meetings: 1, polls: 2, ideas: 3, results: 4 }

    validates :slug, uniqueness: { scope: [:process_id] }
    validates :title, :starts, :ends, presence: true, if: -> { active? }
    validates :stage_type, presence: true
    validates :stage_type, inclusion: { in: stage_types }
    validates :stage_type, uniqueness: { scope: [:process_id] }

    scope :sorted, -> { order(id: :desc) }
    scope :open,   -> { where('starts <= ? AND ends > ?', Time.zone.now, Time.zone.now) }
    scope :active, -> { where(active: true) }

    def open?
      Time.zone.now.between?(starts, ends)
    end

    def active?
      active
    end

    def past?
      ends < Time.zone.now
    end

    def upcoming?
      starts > Time.zone.now
    end

    def current?
      self == process.current_stage
    end

    def to_s
      self.title
    end

  end
end
