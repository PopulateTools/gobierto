# frozen_string_literal: true

class StubbedExternalRequestController < ApplicationController

  def show
    render json: PopulateData::ApiMock.generic_indicator_data
  end

end
