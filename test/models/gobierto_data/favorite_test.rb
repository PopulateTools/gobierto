# frozen_string_literal: true

require "test_helper"

module GobiertoData
  class FavoriteTest < ActiveSupport::TestCase
    def subject
      @subject ||= gobierto_data_favorites(:dennis_users_dataset_favorite)
    end

    def test_valid
      assert subject.valid?
    end
  end
end
