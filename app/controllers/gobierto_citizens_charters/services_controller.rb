# frozen_string_literal: true

class GobiertoCitizensCharters::ServicesController < GobiertoCitizensCharters::ApplicationController

  def index
    @services = base_relation
    @charters = current_site.charters.active
  end

  private

  def base_relation
    current_site.services.active
  end
end
