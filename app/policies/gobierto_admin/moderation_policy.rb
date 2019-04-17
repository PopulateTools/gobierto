# frozen_string_literal: true

module GobiertoAdmin
  class ModerationPolicy < ::GobiertoAdmin::BasePolicy
    attr_reader :moderable

    def initialize(attributes)
      super(attributes)
      @moderable = attributes[:moderable]
    end

    def moderate?
      can_perform_action_on_resource? :moderate
    end

    def edit?
      can_perform_action_on_resource? :edit
    end

    def allowed_to?(next_step)
      !moderable_has_moderation? ||
        moderable.moderation.actions_for_stage(next_step).any? do |action|
          can_perform_action_on_resource?(action)
        end
    end

    def publish_as_editor?
      return true unless moderable_has_moderation?

      edit? && !moderable.moderation_locked_edition?(:visibility_level)
    end

    def publish?
      publish_as_editor? || moderate?
    end

    def moderable_has_moderation?
      moderable.class.include? ::GobiertoCommon::Moderable
    end

    private

    def can_perform_action_on_resource?(action)
      manage? ||
        moderable.permissions_lookup_attributes(action).any? { |lookup_attributes| current_admin.permissions.where(lookup_attributes).exists? }
    end
  end
end
