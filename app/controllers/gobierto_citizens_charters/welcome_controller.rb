# frozen_string_literal: true

class GobiertoCitizensCharters::WelcomeController < GobiertoCitizensCharters::ApplicationController
  def index
    redirect_to GobiertoCitizensCharters.root_path(current_site)
  end
end
