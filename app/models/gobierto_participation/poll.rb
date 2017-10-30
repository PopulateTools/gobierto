# frozen_string_literal: true

require_dependency 'gobierto_participation'

module GobiertoParticipation
  class Poll < ApplicationRecord

    class PollHasAnswers < StandardError; end

    belongs_to :process
    has_many :questions, -> { order(order: :asc) }, class_name: 'GobiertoParticipation::PollQuestion', dependent: :destroy, autosave: true
    has_many :answers, class_name: 'GobiertoParticipation::PollAnswer', autosave: true

    enum visibility_level: { draft: 0, published: 1 }

    scope :open, -> { where("starts_at <= ? AND ends_at >= ?", Time.zone.now, Time.zone.now) }
    scope :answerable, -> { published.open }
    scope :by_site, -> (site) { joins(process: :site).where("sites.id = ? AND gpart_processes.visibility_level = 1
                                                             AND gpart_polls.visibility_level = 1 AND gpart_polls.ends_at >= ?",
                                                             site.id, Time.zone.now) }

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

    def answerable_by?(user)
      answerable? && !has_answers_from?(user)
    end

    def has_answers_from?(user)
      answers.where(user: user).any?
    end

    def open?
      Time.zone.now.between?(starts_at, ends_at)
    end

    def days_left
      (ends_at - Date.current ).to_i
    end

    private

    def ensure_absence_of_answers
      raise PollHasAnswers if unique_answers_count != 0
    end

  end
end
