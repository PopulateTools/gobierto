# frozen_string_literal: true

module GobiertoAdmin
  class AdminResourcesQuery

    class NotImplementedError < StandardError; end

    attr_reader :relation, :permission_action_name

    def initialize(admin, options = {})
      @admin = admin
      @relation = (options[:relation] || model.all)
      @permission_action_name ||= options[:permission_action_name]
      @moderation_stages ||= moderation_keys(options[:moderation_stages])
    end

    def allowed(include_moderated: true)
      if @admin.managing_user?
        relation
      else
        condition = groups_admins_join_table[:admin_id].eq(@admin.id)
        condition = condition.or(moderations_table[:stage].in(@moderation_stages)) if include_moderated
        relation.joins(join_manager.join_sources).distinct.where(condition)
      end
    end

    def join_manager
      @join_manager ||= join_manager_with_groups
        .join(moderations_table, Arel::Nodes::OuterJoin).on(
          model_table[:id].eq(moderations_table[:moderable_id]).and(
            moderations_table[:moderable_type].eq(relation.model.name)
          )
        )
    end

    private

    def join_manager_with_groups
      if permission_action_name.present?
        model_table
          .join(permissions_table, Arel::Nodes::OuterJoin).on(
            model_table[:id].eq(permissions_table[:resource_id]).and(
              permissions_table[:resource_type].eq(relation.model.name)
            ).and(
              permissions_table["action_name"].eq(permission_action_name)
            )
          ).join(groups_admins_join_table, Arel::Nodes::OuterJoin).on(
            groups_admins_join_table[:admin_group_id].eq(permissions_table[:admin_group_id])
          )
      else
        model_table
          .join(groups_table).on(
            model_table[:id].eq(groups_table[:resource_id]).and(
              groups_table[:resource_type].eq(relation.model.name)
            )
          ).join(groups_admins_join_table, Arel::Nodes::OuterJoin).on(
            groups_admins_join_table[:admin_group_id].eq(groups_table[:id])
          )
      end
    end

    def moderation_keys(moderation_stages)
      moderation_stages ||= [:approved]

      moderation_stages.map do |stage|
        ::GobiertoAdmin::Moderation.stages[stage]
      end
    end

    def model_table
      @model_table ||= relation.model.arel_table
    end

    def permissions_table
      @permissions_table ||= ::GobiertoAdmin::GroupPermission.arel_table
    end

    def groups_admins_join_table
      @groups_admins_join_table ||= ::GobiertoAdmin::GroupsAdmin.arel_table
    end

    def groups_table
      @groups_table ||= ::GobiertoAdmin::AdminGroup.arel_table
    end

    def moderations_table
      @moderations_table ||= ::GobiertoAdmin::Moderation.arel_table
    end

    def model
      raise NotImplementedError, "Must override this method"
    end

  end
end
