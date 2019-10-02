# frozen_string_literal: true

module GobiertoParticipation
  module Scopes
    class ActivitiesController < GobiertoParticipation::ApplicationController
      include ::PreviewTokenHelper

      def index
        @scope = find_scope
        @activities = find_scope_activities
      end

      private

      def find_scope_activities
        ActivityCollectionDecorator.new(Activity.in_site(current_site).no_admin.in_process(@scope.processes.public_process).sorted.includes(:subject, :author, :recipient).page(params[:page]))
      end
    end
  end
end
