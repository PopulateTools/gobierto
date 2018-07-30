# frozen_string_literal: true

module GobiertoParticipation
  module Processes
    class ActivitiesController < BaseController
      include ::PreviewTokenHelper

      def index
        @issues = find_issues

        @issue = find_issue if params[:issue_id]

        @activities = if @issue
                        ActivityCollectionDecorator.new(Activity.in_site(current_site)
                                                                .no_admin
                                                                .in_process(current_process)
                                                                .sorted.includes(:subject, :author, :recipient).page(params[:page]))
                      else
                        find_process_activities
                      end
      end

      private

      def find_process_activities
        ActivityCollectionDecorator.new(Activity.in_site(current_site)
                                                .no_admin
                                                .in_process(current_process).sorted.includes(:subject, :author, :recipient).page(params[:page]))
      end
    end
  end
end
