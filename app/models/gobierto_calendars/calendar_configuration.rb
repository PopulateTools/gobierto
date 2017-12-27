# frozen_string_literal: true

require_dependency "gobierto_calendars"

module GobiertoCalendars
  class CalendarConfiguration < ApplicationRecord

    has_many :filtering_rules, dependent: :destroy, autosave: true

    belongs_to :collection, class_name: "GobiertoCommon::Collection"

    validates :collection_id, :integration_name, :data, presence: true
  end
end
