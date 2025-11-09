# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  module GobiertoAdmin
    class TermsIndexTest < ActionDispatch::IntegrationTest

      def setup
        super
        @path = admin_common_vocabulary_terms_path(vocabulary)
      end

      def vocabulary
        gobierto_common_vocabularies(:animals)
      end

      def admin
        @admin ||= gobierto_admin_admins(:tony)
      end

      def unauthorized_admin
        @unauthorized_admin ||= gobierto_admin_admins(:steve)
      end

      def site
        @site ||= sites(:madrid)
      end

      def terms
        @terms ||= vocabulary.terms
      end

      def first_term
        @first_term ||= terms.sorted.first
      end

      def test_permissions
        with_signed_in_admin(unauthorized_admin) do
          with_current_site(site) do
            visit @path

            within "div.v_heading" do
              find("i.fa-caret-square-down").click
            end

            vocabulary.terms.each do |term|
              assert has_content? term.name
              assert has_no_link? term.name
            end
          end
        end
      end

      def test_terms_index
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within ".v_container" do
              assert has_selector?("div.v_el_title", count: terms.size)

              terms.each do |term|
                assert has_content?(term.name)
              end
            end
          end
        end
      end

      def test_terms_order
        terms.update_all(term_id: nil, level: 0)

        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path
            ordered_names = page.all(:css, "div.v_el_title").map(&:text)
            assert_equal terms.sorted.map(&:name), ordered_names

            first_term.update_attribute(:position, 1000)

            visit @path
            ordered_names = page.all(:css, "div.v_el_title").map(&:text)
            assert_equal first_term.name, ordered_names.last
          end
        end
      end
    end
  end
end
