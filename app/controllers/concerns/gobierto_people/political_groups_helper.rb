module GobiertoPeople
  module PoliticalGroupsHelper
    extend ActiveSupport::Concern

    private

    def get_political_groups
      PoliticalGroup.includes(:people).where.not(gp_people: {political_group_id: nil}).where(gp_people:{site_id: current_site.id, visibility_level: 1}).all
    end
  end
end
