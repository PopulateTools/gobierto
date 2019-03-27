# frozen_string_literal: true

class GobiertoCalendars::EventLocationSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :lat, :lng
end
