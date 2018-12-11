# frozen_string_literal: true

module GobiertoParticipation
  class WelcomeController < GobiertoParticipation::ApplicationController
    include LiquidHelper

    def index
      @processes = current_site.processes.process.active
      @issues = find_issues
      @events = find_participation_events
      @news = find_participation_news
      @activities = find_participation_activities

      template_content = ::GobiertoCore::SiteTemplate.liquid_str(current_site, "gobierto_participation/welcome/index")

      render inline: template_content, type: :liquid, layout: "gobierto_participation/layouts/application"
    end

    private

    def find_participation_events
      ProcessCollectionDecorator.new(current_site.events).in_participation_module.published.sorted.upcoming.limit(4)
    end

    def find_participation_news
      ProcessCollectionDecorator.new(current_site.pages, item_type: "GobiertoCms::News").in_participation_module.active.sorted.limit(5)
    end

    def find_participation_activities
      ActivityCollectionDecorator.new(Activity.in_site(current_site).no_admin.in_participation(current_site).sorted.limit(5).includes(:subject, :author, :recipient))
    end
  end
end
