# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class GiftTest < ActiveSupport::TestCase

    def encyclopedia
      @encyclopedia ||= gobierto_people_gifts(:encyclopedia)
    end

    def concert_ticket
      @concert_ticket ||= gobierto_people_gifts(:concert_ticket)
    end

    def test_type
      assert_equal "Bibliographic materials", encyclopedia.type
      assert_nil concert_ticket.type
    end

  end
end
