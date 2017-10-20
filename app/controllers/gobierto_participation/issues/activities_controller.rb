# frozen_string_literal: true

module GobiertoParticipation
  module Issues
    class ActivitiesController < GobiertoParticipation::BaseController
      include ::PreviewTokenHelper

      def index
        @issue = find_issue
        @activities = find_issue_activities
      end

      private

      def find_issue
        current_site.issues.find_by_slug!(params[:issue_id])
      end

      def find_issue_activities
        ActivityCollectionDecorator.new(Activity.in_site(current_site).no_admin.in_container(@issue).sorted.includes(:subject, :author, :recipient).page(params[:page]))
      end
    end
  end
end
