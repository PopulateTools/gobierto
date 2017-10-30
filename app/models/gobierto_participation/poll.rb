# frozen_string_literal: true

require_dependency 'gobierto_participation'

module GobiertoParticipation
  class Poll < ApplicationRecord

    class PollHasAnswers < StandardError; end

    include PollResultsHelpers

    belongs_to :process
    has_many :questions, -> { order(order: :asc) }, class_name: 'GobiertoParticipation::PollQuestion', dependent: :destroy, autosave: true
    has_many :answers, class_name: 'GobiertoParticipation::PollAnswer', autosave: true

    enum visibility_level: { draft: 0, published: 1 }
    enum visibility_user_level: { registered: 0, verified: 1 }

    scope :open, -> { where("starts_at <= ? AND ends_at >= ?", Time.zone.now, Time.zone.now) }
    scope :answerable, -> { published.open }
    scope :by_site, -> (site) { joins(process: :site).where("sites.id = ? AND gpart_processes.visibility_level = 1
                                                             AND gpart_polls.visibility_level = 1 AND gpart_polls.ends_at >= ?",
                                                             site.id, Time.zone.now) }

    translates :title, :description

    before_save :ensure_editable!

    accepts_nested_attributes_for :questions, allow_destroy: true

    validates_associated :questions, message: I18n.t('activerecord.messages.gobierto_participation/poll.are_not_valid')

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

    def closed?
      !open?
    end

    def editable?
      unique_answers_count == 0
    end

    def upcoming?
      starts_at > Time.zone.now
    end

    def past?
      ends_at < Time.zone.now
    end

    private

    def ensure_editable!
      raise PollHasAnswers if !editable?
    end

  end
end
