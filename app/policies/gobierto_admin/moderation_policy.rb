# frozen_string_literal: true

module GobiertoAdmin
  class ModerationPolicy < ::GobiertoAdmin::BasePolicy
    attr_reader :moderable, :actions_manager

    def initialize(attributes)
      super(attributes)
      @moderable = attributes[:moderable]
      module_namespace = moderable.class.name.deconstantize
      @actions_manager = ::GobiertoAdmin::AdminActionsManager.for(module_namespace, current_site)
    end

    def moderate?
      can_perform_action_on_resource? :moderate_projects
    end

    def edit?
      can_perform_action_on_resource? :edit_projects
    end

    def manage_groups?
      can_perform_action_on_resource? :manage
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
      can_perform_action_on_resource? :publish_projects
    end

    def moderable_has_moderation?
      moderable.class.include? ::GobiertoCommon::Moderable
    end

    private

    def can_perform_action_on_resource?(action)
      manage? || actions_manager.action_allowed?(admin: current_admin, action_name: action, resource: moderable)
    end
  end
end
