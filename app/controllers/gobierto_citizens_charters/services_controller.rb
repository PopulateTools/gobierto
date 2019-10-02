# frozen_string_literal: true

class GobiertoCitizensCharters::ServicesController < GobiertoCitizensCharters::ApplicationController

  before_action :overrided_root_redirect, only: [:index]

  def index
    @services = base_relation
    @charters = current_site.charters.active
  end

  private

  def base_relation
    current_site.services.active
  end
end
