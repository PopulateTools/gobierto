# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    module ContentBlocks
      class ContentBlockCreateTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = new_admin_common_content_block_path(content_context: content_context.model_name.name)
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

        def content_context
          ::GobiertoPeople::Person.new
        end

        def test_content_block_create
          with(js: true) do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                within "form.new_content_block" do
                  within ".title_components" do
                    AVAILABLE_LOCALES.each do |locale|
                      fill_in I18n.t("locales.#{locale}"), with: "Content block title in #{locale}"
                    end
                  end

                  within ".content-block-field-record-new" do
                    select "Date", from: "Field type"

                    AVAILABLE_LOCALES.each do |locale|
                      fill_in I18n.t("locales.#{locale}"), with: "Content block field in #{locale}"
                    end
                  end

                  find("a[data-behavior=add_child]").click

                  within ".cloned-dynamic-content-record-wrapper" do
                    select "Text", from: "Field type"

                    AVAILABLE_LOCALES.each do |locale|
                      fill_in I18n.t("locales.#{locale}"), with: "Child content block field in #{locale}"
                    end
                  end

                  click_button "Create"
                end

                assert has_message?("Content block was successfully created")

                within "form.edit_content_block" do
                  within ".title_components" do
                    AVAILABLE_LOCALES.each do |locale|
                      assert has_field?(I18n.t("locales.#{locale}"), with: "Content block title in #{locale}")
                    end
                  end

                  all(".dynamic-content-record-wrapper").each do |_content_block_field|
                    assert has_select?("Field type", selected: "Date")

                    AVAILABLE_LOCALES.each do |locale|
                      assert has_field?(I18n.t("locales.#{locale}"), with: "Content block field in #{locale}")
                    end
                  end
                end
              end
            end
          end
        end

        def test_content_block_create_for_regular_admin
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
