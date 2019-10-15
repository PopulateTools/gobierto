# frozen_string_literal: true

module GobiertoParticipation
  class ActivitiesController < GobiertoParticipation::ApplicationController
    def index
      @issues = find_issues

      @issue = find_issue if params[:issue_id]

      @activities = if @issue
                      find_participation_activities_issue(@issue)
                    else
                      find_participation_activities
                    end
    end

    private

    def find_participation_activities_issue(issue)
      ActivityCollectionDecorator.new(Activity.no_admin
                                              .in_site(current_site)
                                              .in_process(issue.processes.open_process)
                                              .sorted.includes(:subject, :author, :recipient).page(params[:page]))
    end

    def find_participation_activities
      ActivityCollectionDecorator.new(Activity.no_admin.in_site(current_site).in_participation(current_site).sorted.includes(:subject, :author, :recipient).page(params[:page]))
    end
  end
end
