# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class FlagTest < ActiveSupport::TestCase
    def flag
      @flag ||= gobierto_participation_flags(:contribution_flag)
    end

    def test_valid
      assert flag.valid?
    end
  end
end
