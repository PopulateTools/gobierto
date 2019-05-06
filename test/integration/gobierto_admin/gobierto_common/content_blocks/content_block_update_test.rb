# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    module ContentBlocks
      class ContentBlockUpdateTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = edit_admin_common_content_block_path(content_block)
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def regular_admin
          @regular_admin ||= gobierto_admin_admins(:tony)
        end

        def site
          @site ||= sites(:madrid)
        end

        def content_block
          @content_block ||= gobierto_common_content_blocks(:contact_methods)
        end

        def test_content_block_update
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                within "form.edit_content_block" do
                  within ".title_components" do
                    AVAILABLE_LOCALES.each do |locale|
                      fill_in I18n.t("locales.#{locale}"), with: "Content block title in #{locale}"
                    end
                  end

                  content_block.fields.each do |content_block_field|
                    within ".content-block-field-record-#{content_block_field.id}" do
                      select "Currency", from: "Field type"

                      AVAILABLE_LOCALES.each do |locale|
                        fill_in I18n.t("locales.#{locale}"), with: "Content block field in #{locale}"
                      end
                    end
                  end

                  find("a[data-behavior=add_child]").click

                  within ".cloned-dynamic-content-record-wrapper" do
                    select "Text", from: "Field type"

                    AVAILABLE_LOCALES.each do |locale|
                      fill_in I18n.t("locales.#{locale}"), with: "Child content block field in #{locale}"
                    end
                  end

                  click_button "Update"
                end

                assert has_message?("Content block was successfully updated")

                within "form.edit_content_block" do
                  within ".title_components" do
                    AVAILABLE_LOCALES.each do |locale|
                      assert has_field?(I18n.t("locales.#{locale}"), with: "Content block title in #{locale}")
                    end
                  end

                  content_block.fields.each do |content_block_field|
                    within ".content-block-field-record-#{content_block_field.id}" do
                      assert has_select?("Field type", selected: "Currency")

                      AVAILABLE_LOCALES.each do |locale|
                        assert has_field?(I18n.t("locales.#{locale}"), with: "Content block field in #{locale}")
                      end
                    end
                  end
                end
              end
            end
          end
        end

        def test_content_block_update_for_regular_admin
          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit @path

              assert has_message?("You are not authorized to perform this action")
            end
          end
        end
      end
    end
  end
end
