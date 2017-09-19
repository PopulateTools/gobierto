require_dependency 'gobierto_participation'

module GobiertoParticipation
  class Poll < ApplicationRecord

    class PollHasAnswers < StandardError; end

    belongs_to :process
    has_many :questions, -> { order(order: :asc) }, class_name: 'GobiertoParticipation::PollQuestion', dependent: :destroy, autosave: true
    has_many :answers, class_name: 'GobiertoParticipation::PollAnswer'

    enum visibility_level: { draft: 0, published: 1 }

    translates :title, :description

    before_save :ensure_absence_of_answers

    accepts_nested_attributes_for :questions, allow_destroy: true

    validates_associated :questions, message: I18n.t('activerecord.messages.gobierto_participation/poll.are_not_valid')

    def unique_answers_count
      answers.select('DISTINCT user_id').count
    end

    def answerable?
      published? && open?
    end

    def open?
      Time.zone.now.between?(starts_at, ends_at)
    end

    private

    def ensure_absence_of_answers
      raise PollHasAnswers if unique_answers_count != 0
    end

  end
end
