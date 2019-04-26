# frozen_string_literal: true

require "test_helper"
require "support/populate_data/api_mock"

module GobiertoObservatory
  module Observatory
    class IndexTest < ActionDispatch::IntegrationTest

      def site
        @site ||= sites(:madrid)
      end

      def first_card
        first(".card_container")
      end

      def first_card_front
        first_card.find(".front")
      end

      def first_card_back
        first_card.find(".back")
      end

      def first_card_back_visible?
        first_card["class"].include?("hover")
      end

      def test_index
        with(site: site, js: true) do
          PopulateData::ApiMock.stub_endpoint

          visit gobierto_observatory_root_path

          assert_equal "Inhabitants", first_card_front.find("h3").text
          assert first_card_front.text.include?("INE")
          assert first_card_back.text.include?("Indicator description")
        end
      end

      def test_flip_card
        with(site: site, js: true) do
          PopulateData::ApiMock.stub_endpoint

          visit gobierto_observatory_root_path

          refute first_card_back_visible?

          first_card.find(".fa-question-circle").click

          assert first_card_back_visible?
        end
      end

    end
  end
end
