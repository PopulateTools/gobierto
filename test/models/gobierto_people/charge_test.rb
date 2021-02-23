# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_common/has_external_id_test"

module GobiertoPeople
  class ChargeTest < ActiveSupport::TestCase
    include GobiertoCommon::HasExternalIdTest

    def subject
      ::GobiertoPeople::Charge
    end

    def charge
      @charge ||= gobierto_people_charges(:richard_avenger)
    end

    def test_valid
      assert charge.valid?
    end
  end
end
