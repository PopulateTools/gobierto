# frozen_string_literal: true

module GobiertoParticipation
  module Issues
    class NotificationsController < BaseController
      include ::PreviewTokenHelper

      def index
        @issues = current_site.issues.alphabetically_sorted

        @issue = find_issue if params[:issue_id]

        @activities = find_issue_activities
      end

      private

      def find_issue
        current_site.issues.find_by_slug!(params[:issue_id])
      end

      def find_issue_activities
        ActivityCollectionDecorator.new(Activity.in_site(current_site).in_container(@issue).sorted.includes(:subject, :author, :recipient).page(params[:page]))
      end
    end
  end
end
