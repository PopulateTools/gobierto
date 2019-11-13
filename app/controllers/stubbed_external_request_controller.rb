# frozen_string_literal: true

class StubbedExternalRequestController < ApplicationController

  def populate_data_indicator
    render json: PopulateData::ApiMock.generic_indicator_data
  end

  def bubbles_file
    render json: JSON.parse(File.read("#{Rails.root}/test/fixtures/files/bubbles.json"))
  end

end
