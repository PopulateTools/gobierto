# frozen_string_literal: true

module GobiertoPeople
  module PoliticalGroupsHelper
    extend ActiveSupport::Concern

    private

    def get_political_groups
      PoliticalGroup.all
    end
  end
end
