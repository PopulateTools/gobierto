# frozen_string_literal: true

require 'test_helper'
require 'support/populate_data_helpers'

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class BudgetLineCollectionBuilderTest < ActiveSupport::TestCase
      include PopulateDataHelpers

      def budget_line_collection_builder
        @budget_line_collection_builder ||= begin
          BudgetLineCollectionBuilder.new(site, year: 2016)
        end
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_call
        with_stubbed_populate_data do
          assert_equal [populate_data_budget_line_summary], budget_line_collection_builder.call
        end
      end
    end
  end
end
