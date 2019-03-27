# frozen_string_literal: true

require_relative "base"

module GobiertoPeople
  module People
    module BaseIndex
      include Base
      def test_missing_data_person_navigation
        person.update(bio: "")
        person.update(bio_translations: person.bio_translations.transform_values { "" })
        person.update(bio_url: nil)
        person.content_blocks(person.site_id).destroy_all
        person.posts.active.each { |post| post.delete }
        person.statements.active.each { |statement| statement.delete }

        with_current_site(site) do
          visit @path
          within ".people-navigation" do
            assert has_no_link?("Biography and CV")
            assert has_no_link?("Blog")
            assert has_no_link?("Goods and Activities")
          end
        end
      end
    end
  end
end
