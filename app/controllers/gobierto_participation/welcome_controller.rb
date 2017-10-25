# frozen_string_literal: true

module GobiertoParticipation
  class WelcomeController < GobiertoParticipation::ApplicationController
    def index
      @processes = current_site.processes.process.active
      @issues = current_site.issues.alphabetically_sorted
      @events = find_participation_events
      @news = find_participation_news
      @activities = find_participation_activities
    end

    private

    def find_participation_events
      ::GobiertoCalendars::Event.events_in_collections_and_container_type(current_site, "GobiertoParticipation").sorted.upcoming.limit(4)
    end

    def find_participation_news
      ::GobiertoCms::Page.pages_in_collections_and_container_type(current_site, "GobiertoParticipation").active.sorted.limit(5)
    end

    def find_participation_activities
      ActivityCollectionDecorator.new(Activity.in_site(current_site).no_admin.in_participation.sorted.limit(5).includes(:subject, :author, :recipient))
    end
  end
end
