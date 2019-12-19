# frozen_string_literal: true

require "test_helper"

module GobiertoData
  class QueryTest < ActiveSupport::TestCase
    def subject
      @subject ||= gobierto_data_queries(:users_count_query)
    end

    def test_valid
      assert subject.valid?
    end
  end
end
