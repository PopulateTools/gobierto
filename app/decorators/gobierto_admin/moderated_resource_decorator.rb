# frozen_string_literal: true

module GobiertoAdmin
  class ModeratedResourceDecorator < BaseDecorator
    def initialize(resource)
      @object = resource
    end

    def has_publication_status?
      @has_publication_status ||= respond_to?(:visibility_level)
    end

    def publication_status
      @publication_status ||= publicable? && visibility_level == unpublished_value ? :not_published : :approved
    end

    def published?
      @published ||= publication_status == :approved
    end

    # This method will change with moderation concern
    def publicable?
      @publicable ||= true
    end

    # This method will change with moderation concern
    def sent?
      @sent ||= false
    end

    def step
      @step ||= if publicable?
                  published? ? :published : :publicable
                elsif new_record?
                  :new
                elsif sent?
                  :sent
                else
                  :pending
                end
    end

    def locked?
      @locked ||= [:new, :pending].include?(step)
    end

    def step_action
      MODERATION_STEPS[step][:action]
    end

    def moderation_status
      MODERATION_STEPS[step][:moderation_status]
    end

    def moderation_style
      MODERATION_STEPS[step][:moderation_style]
    end

    def step_disabled?
      MODERATION_STEPS[step][:disabled]
    end

    def step_visibility_value
      @step_visibility_value ||= published? ? unpublished_value : (self.class.visibility_levels.keys - [unpublished_value]).first
    end

    private

    MODERATION_STEPS = { new: { action: :send, moderation_status: :not_sent, disabled: true, moderation_style: :not_published },
                         pending: { action: :send, moderation_status: :not_sent, disabled: false, moderation_style: :not_published },
                         sent: { action: :publish, moderation_status: :under_review, disabled: true, moderation_style: :in_revision },
                         publicable: { action: :publish, moderation_status: :approved, disabled: false, moderation_style: :approved },
                         published: { action: :unpublish, moderation_status: :approved, disabled: false, moderation_style: :approved } }.freeze

    def unpublished_value
      "draft"
    end
  end
end
