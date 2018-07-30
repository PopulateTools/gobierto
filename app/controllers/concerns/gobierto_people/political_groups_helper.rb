# frozen_string_literal: true

module GobiertoPeople
  module PoliticalGroupsHelper
    extend ActiveSupport::Concern

    private

    def get_political_groups
      person_table = Person.table_name
      join_clause = "JOIN #{person_table} ON #{person_table}.political_group_id = terms.id"
      current_site.political_groups.distinct.joins(join_clause).where.not(
        person_table => {
          political_group_id: nil
        }
      ).where(
        person_table => {
          site_id: current_site.id,
          visibility_level: 1
        }
      ).all
    end
  end
end
