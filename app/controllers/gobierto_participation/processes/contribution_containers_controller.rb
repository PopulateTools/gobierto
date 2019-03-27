# frozen_string_literal: true

module GobiertoParticipation
  module Processes
    class ContributionContainersController < BaseController

      def index
        @contribution_containers = current_process.contribution_containers.active
      end

      def show
        @contribution_container = contribution_containers_scope.find_by!(slug: params[:id])

        data_origin = @contribution_container.contributions
        data_best_ratings = @contribution_container.contributions.loved
        data_worst_ratings = @contribution_container.contributions.hated
        data_recent = @contribution_container.contributions.created_at_last_week

        users_ideas_origin = I18n.t("gobierto_participation.processes.contribution_containers.show.user",
                                    count: @contribution_container.contributions.distinct.count(:user_id)) + " " +
                             I18n.t("gobierto_participation.processes.contribution_containers.show.#{@contribution_container.contribution_type}",
                                    count: @contribution_container.contributions.count)

        users_best_ratings = I18n.t("gobierto_participation.processes.contribution_containers.show.user",
                                    count: @contribution_container.contributions.loved.distinct.count(:user_id)) + " " +
                             I18n.t("gobierto_participation.processes.contribution_containers.show.#{@contribution_container.contribution_type}",
                                    count: @contribution_container.contributions.loved.count)

        users_worst_ratings = I18n.t("gobierto_participation.processes.contribution_containers.show.user",
                                     count: @contribution_container.contributions.hated.distinct.count(:user_id)) + " " +
                              I18n.t("gobierto_participation.processes.contribution_containers.show.#{@contribution_container.contribution_type}",
                                     count: @contribution_container.contributions.hated.count)

        users_recent = I18n.t("gobierto_participation.processes.contribution_containers.show.user",
                              count: @contribution_container.contributions.created_at_last_week.distinct.count(:user_id)) + " " +
                       I18n.t("gobierto_participation.processes.contribution_containers.show.#{@contribution_container.contribution_type}",
                              count: @contribution_container.contributions.created_at_last_week.count)

        @contribution_container_data = { data_origin: data_origin.json_attributes,
                                         data_best_ratings: data_best_ratings.json_attributes,
                                         data_worst_ratings: data_worst_ratings.json_attributes,
                                         data_recent: data_recent.json_attributes,
                                         users_ideas_origin: users_ideas_origin,
                                         users_best_ratings: users_best_ratings,
                                         users_worst_ratings: users_worst_ratings,
                                         users_recent: users_recent
                                       }

        if current_user
          @contribution_container_data[:data_self] = @contribution_container.contributions.with_user(current_user)
          @contribution_container_data[:user] =  I18n.t("gobierto_participation.processes.contribution_containers.show.user", count: @contribution_container.contributions.with_user(current_user).count(:user_id)) + " " +
                 I18n.t("gobierto_participation.processes.contribution_containers.show.#{@contribution_container.contribution_type}", count: @contribution_container.contributions.with_user(current_user).count)
        end
      end

      private

      def contribution_containers_scope
        if valid_preview_token?
          current_process.contribution_containers
        else
          current_process.contribution_containers.active
        end
      end

    end
  end
end
