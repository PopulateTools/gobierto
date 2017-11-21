module GobiertoPeople
  module PoliticalGroupsHelper
    extend ActiveSupport::Concern

    private

    def get_political_groups
      PoliticalGroup.includes(:people).where.not(gp_people: {political_group_id: nil, visibility_level: 0}).all
    end
  end
end
