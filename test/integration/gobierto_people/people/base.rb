# frozen_string_literal: true

module GobiertoPeople
  module People
    module Base
      def test_person_navigation
        with_current_site(site) do
          visit @path

          within ".people-navigation" do
            assert has_link?("Biography and CV")
            assert has_link?("Agenda")
            assert has_link?("Blog")
            assert has_link?("Goods and Activities")
          end
        end
      end

      def test_person_contact_methods
        with_current_site(site) do
          visit @path

          within ".contact-methods" do
            assert has_link?("@richard", href: "https://twitter.com/richard")
            assert has_link?("@richard", href: "https://facebook.com/richard")
            assert has_link?("@richard", href: "https://linkedin.com/richard")
            assert has_link?("@richard", href: "https://instagram.com/richard")
          end
        end
      end

      def test_person_avatar
        with_current_site(site) do
          visit @path

          assert has_css?("img.avatar[src='#{person.avatar_url}']")
        end
      end
    end
  end
end
