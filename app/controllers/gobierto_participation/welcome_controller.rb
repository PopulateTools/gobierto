# frozen_string_literal: true

module GobiertoParticipation
  class WelcomeController < GobiertoParticipation::ApplicationController
    include LiquidHelper

    def index
      @processes = current_site.processes.process.active
      @issues = current_site.issues
      @events = find_participation_events
      @news = find_participation_news
      @activities = find_participation_activities

      liquid_path = params[:controller] + "/" + action_name + ".liquid"

      liquid_str = if current_site_has_custom_template?(liquid_path)
                     current_site_custom_template(liquid_path).first.markup
                   else
                     File.read("app/views/" + liquid_path)
                   end

      liquid = to_liquid(liquid_str)
      liquid_rendered = liquid.render({ "location_name" => current_site.location_name },
                                      registers: { controller: self })

      render inline: liquid_rendered.html_safe, layout: "gobierto_participation/layouts/application"
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
