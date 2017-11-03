# frozen_string_literal: true

module GobiertoParticipation
  class ActivitiesController < BaseController
    def index
      @issues = current_site.issues

      @issue = find_issue if params[:issue_id]

      @activities = if @issue
                      find_participation_activities_issue(@issue)
                    else
                      find_participation_activities
                    end
    end

    private

    def find_issue
      current_site.issues.find_by_slug!(params[:issue_id])
    end

    def find_participation_activities_issue(issue)
      ActivityCollectionDecorator.new(Activity.no_admin
                                              .in_site(current_site)
                                              .in_container(issue)
                                              .sorted.includes(:subject, :author, :recipient).page(params[:page]))
    end

    def find_participation_activities
      ActivityCollectionDecorator.new(Activity.no_admin.in_site(current_site).in_participation.sorted.includes(:subject, :author, :recipient).page(params[:page]))
    end
  end
end
