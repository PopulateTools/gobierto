# frozen_string_literal: true

class ApiBaseController < ApplicationController

  respond_to :json

  skip_before_action :verify_authenticity_token

end
