# frozen_string_literal: true

require "test_helper"

module GobiertoCitizensCharters
  class ServiceTest < ActiveSupport::TestCase
    def service
      @service ||= gobierto_citizens_charters_services(:teleassistance)
    end

    def test_valid
      assert service.valid?
    end
  end
end
