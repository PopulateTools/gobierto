# frozen_string_literal: true

module GobiertoParticipation
  class Poll < ApplicationRecord
    class PollHasAnswers < StandardError; end

    acts_as_paranoid column: :archived_at

    include ActsAsParanoidAliases
    include GobiertoCommon::HasVisibilityUserLevels
    include GobiertoCommon::UrlBuildable
    include PollResultsHelpers

    belongs_to :process
    delegate :site, to: :process, allow_nil: true
    has_many :questions, -> { order(order: :asc) }, class_name: "GobiertoParticipation::PollQuestion", dependent: :destroy, autosave: true
    has_many :answers, class_name: "GobiertoParticipation::PollAnswer", autosave: true

    enum visibility_level: { draft: 0, published: 1 }

    scope :open, -> { where("starts_at <= ? AND ends_at >= ?", Time.zone.now, Time.zone.now) }
    scope :answerable, -> { published.open }
    scope :by_site, -> (site) { joins(process: :site).where("sites.id = ? AND gpart_processes.visibility_level = 1
                                                             AND gpart_polls.visibility_level = 1 AND gpart_polls.ends_at >= ?",
                                                             site.id, Time.zone.now) }

    translates :title, :description

    before_save :ensure_editable!

    accepts_nested_attributes_for :questions, allow_destroy: true

    validates_associated :questions, message: I18n.t("activerecord.messages.gobierto_participation/poll.are_not_valid")

    validates :title, presence: true

    def answerable?
      published? && open?
    end

    def answerable_by?(user)
      answerable? && !has_answers_from?(user)
    end

    def has_answers_from?(user)
      answers.by_user(user).any?
    end

    def open?
      date = Time.zone.now.to_date
      starts_at <= date && ends_at >= date
    end

    def closed?
      !open?
    end

    def editable?
      unique_answers_count.zero?
    end

    def upcoming?
      starts_at > Time.zone.now
    end

    def past?
      ends_at < Time.zone.now
    end

    def parameterize
      { process_id: process.slug, poll_id: id }
    end

    # always include preview token since the admin may not have session in the front
    def admin_preview_url(admin)
      options = parameterize.merge(host: site.domain)
      options[:preview_token] = admin.preview_token

      url_helpers.send("#{singular_route_key}_url", options)
    end

    private

    def ensure_editable!
      raise PollHasAnswers unless editable?
    end

    def singular_route_key
      :new_gobierto_participation_process_poll_answer
    end

  end
end
