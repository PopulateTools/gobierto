# frozen_string_literal: true

module GobiertoAdmin
  class WelcomeController < BaseController
    def index
      @activities = if current_admin.manager? || current_admin.god?
                      ActivityCollectionDecorator.new(Activity.where(site_id: current_site).or(Activity.where(site_id: nil)).sorted.includes(:subject, :author, :recipient).page(params[:page]))
                    else
                      ActivityCollectionDecorator.new(Activity.in_site(current_site).sorted.includes(:subject, :author, :recipient).page(params[:page]))
                    end
      render 'gobierto_admin/activities/index'
    end
  end
end
