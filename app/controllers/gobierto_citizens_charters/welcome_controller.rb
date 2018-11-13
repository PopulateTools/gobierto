# frozen_string_literal: true

class GobiertoCitizensCharters::WelcomeController < GobiertoCitizensCharters::ApplicationController
  def index
    path = if services_home_enabled?
             gobierto_citizens_charters_services_path
           else
             reference_edition = ::GobiertoCitizensCharters::CharterDecorator.new(current_site).reference_edition
             gobierto_citizens_charters_charters_period_path(reference_edition.front_period_params)
           end
    redirect_to path
  end
end
