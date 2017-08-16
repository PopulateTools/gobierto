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
    scope :open,   -> { where('starts <= ? AND ends > ?', Time.zone.now, Time.zone.now) }

    def open?
      Time.zone.now.between?(starts, ends)
    end

    def past?
      ends < Time.zone.now
    end

    def upcoming?
      starts > Time.zone.now
    end

    def current?
      self == process.stages.open.order(ends: :asc).last
    end

    def to_s
      self.title
    end

  end
end
