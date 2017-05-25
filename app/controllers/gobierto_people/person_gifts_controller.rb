# frozen_string_literal: true

module GobiertoPeople
  class PersonGiftsController < GobiertoPeople::ApplicationController
    before_action :check_active_submodules

    def index
      redirect_to(gifts_service_url) && return if gifts_service_url.present?

      redirect_to :back, notice: t('.error')
    end

    private

    def check_active_submodules
      redirect_to gobierto_people_root_path unless statements_submodule_active?
    end

    def gifts_service_url
      APP_CONFIG.dig('gobierto_people', 'gifts_service_url')
    end
  end
end
