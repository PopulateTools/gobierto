require_dependency 'gobierto_calendars'

module GobiertoCalendars
  class CalendarConfiguration < ApplicationRecord

    belongs_to :collection, class_name: 'GobiertoCommon::Collection'

    validates :collection_id, :integration_name, :data, presence: true
  end
end
