# frozen_string_literal: true

module GobiertoAdmin
  class ModeratedResourceDecorator < BaseDecorator
    attr_accessor :current_admin, :moderation_policy

    delegate :moderable_has_moderation?, to: :moderation_policy

    def initialize(resource, opts = {})
      @object = resource
      @current_admin = opts.delete(:current_admin)
      @current_site = opts.delete(:current_site)
      @moderation_policy = GobiertoAdmin::ModerationPolicy.new(current_admin: @current_admin, current_site: @current_site, moderable: @object)
    end

    def has_publication_status?
      @has_publication_status ||= respond_to?(:visibility_level)
    end

    def publication_status
      @publication_status ||= has_publication_status? && visibility_level == unpublished_value ? :not_published : :approved
    end

    def published?
      @published ||= publication_status == :approved
    end

    def publicable?
      @publicable ||= !moderable_has_moderation? || moderation.approved? || (moderation_policy.publish? && !published?)
    end

    def sent?
      @sent ||= moderable_has_moderation? && !moderation.unsent?
    end

    def rejected?
      @rejected ||= moderable_has_moderation? && moderation.rejected?
    end

    def moderation_confirm_data
      if persisted? && moderable_has_moderation? && !moderation.sent?
        { confirm: I18n.t("gobierto_admin.shared.moderation_save_widget.confirm_moderation_blocked_update") }
      end
    end

    def publish_moderation_step
      @publish_moderation_step ||= if new_record?
                                     :new
                                   elsif publicable?
                                     published? ? :published : :publicable
                                   elsif sent?
                                     rejected? ? :rejected : :sent
                                   else
                                     :unsent
                                   end
    end

    def locked?
      @locked ||= [:new, :unsent].include?(publish_moderation_step)
    end

    def has_preview?
      false
    end

    def publish_step_action
      publish_moderation_status.action || visibility_level_change_action
    end

    def visibility_level_change_action
      published? ? :unpublish : :publish
    end

    def moderation_status
      moderable_has_moderation? ? moderation_stage.to_sym : publish_moderation_status.moderation_status
    end

    def moderation_style
      publish_moderation_status.moderation_style
    end

    def step_disabled?
      publish_moderation_status.disabled && !moderation_policy.publish?
    end

    def step_visibility_value
      @step_visibility_value ||= published? ? unpublished_value : step_published_value
    end

    def step_published_value
      @step_published_value ||= (self.class.visibility_levels.keys - [unpublished_value]).first
    end

    def moderation_reachable_stages
      @moderation_reachable_stages ||= begin
                                         reachable_stages = moderation.reachable_stages_for_action(:moderate)
                                         moderation.class.stages.select { |stage, _| reachable_stages.include?(stage) }
                                       end
    end

    def status_style_class(staus_text)
      Hash[PUBLISH_MODERATION_STEPS.values.map do |dic|
        [dic[:moderation_status], dic[:moderation_style]]
      end][staus_text.to_sym] || :in_revision
    end

    def publish_step_action_confirm_message
      if @object.is_a?(::GobiertoPlans::Node)
        I18n.t("gobierto_admin.gobierto_plans.projects.#{publish_step_action}.confirm")
      else
        I18n.t("gobierto_admin.shared.moderation_save_widget.confirm")
      end
    end

    private

    def publish_moderation_status
      @publish_moderation_status ||= OpenStruct.new PUBLISH_MODERATION_STEPS[publish_moderation_step]
    end

    PUBLISH_MODERATION_STEPS = { new: { action: :send, moderation_status: :unsent, disabled: true, moderation_style: :not_published },
                                 unsent: { action: :send, moderation_status: :unsent, disabled: false, moderation_style: :not_published },
                                 sent: { moderation_status: :in_review, disabled: true, moderation_style: :in_revision },
                                 publicable: { moderation_status: :approved, disabled: false, moderation_style: :approved },
                                 published: { moderation_status: :approved, disabled: false, moderation_style: :approved },
                                 rejected: { moderation_status: :rejected, disabled: true, moderation_style: :not_published } }.freeze

    def unpublished_value
      "draft"
    end
  end
end
