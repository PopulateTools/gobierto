# frozen_string_literal: true

module GobiertoParticipation
  class WelcomeController < GobiertoParticipation::ApplicationController
    def index
      @processes = current_site.processes.process.active
      @issues = current_site.issues.alphabetically_sorted
      @participation_events = find_participation_events
      @participation_news = find_participation_news
      @participation_activities = find_participation_activities
    end

    private

    def find_participation_events
      ::GobiertoCalendars::Event.events_in_collections_and_container_type(current_site, "GobiertoParticipation").sorted.published
    end

    def find_participation_news
      ::GobiertoCms::Page.pages_in_collections_and_container_type(current_site, "GobiertoParticipation").sorted.active
    end

    def find_participation_activities
      ActivityCollectionDecorator.new(Activity.in_site(current_site).participation.sorted.includes(:subject, :author, :recipient).limit(5))
    end
  end
end
