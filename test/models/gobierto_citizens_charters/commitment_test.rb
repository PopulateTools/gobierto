# frozen_string_literal: true

require "test_helper"

module GobiertoCitizensCharters
  class CommitmentTest < ActiveSupport::TestCase
    def commitment
      @commitment ||= gobierto_citizens_charters_commitments(:call_center_service_level)
    end

    def test_valid
      assert commitment.valid?
    end
  end
end
