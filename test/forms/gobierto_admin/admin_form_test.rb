require "test_helper"

module GobiertoAdmin
  class AdminFormTest < ActiveSupport::TestCase
    def valid_admin_form
      @valid_admin_form ||= AdminForm.new(
        authorization_level: 'manager',
        name: admin.name,
        email: new_admin_email, # To ensure uniqueness
        password: "gobierto",
        password_confirmation: "gobierto"
      )
    end

    def invalid_admin_form
      @invalid_admin_form ||= AdminForm.new(
        name: nil,
        email: nil,
        password: nil,
        password_confirmation: nil
      )
    end

    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def new_admin_email
      "wadus@gobierto.dev"
    end

    def test_save_with_valid_attributes
      assert valid_admin_form.save
    end

    def test_error_messages_with_valid_attributes_and_not_matching_passwords
      valid_admin_form.password_confirmation = "wadus"

      valid_admin_form.save

      assert_equal 0, valid_admin_form.errors.messages[:password].size
      assert_equal 1, valid_admin_form.errors.messages[:password_confirmation].size
    end

    def test_error_messages_with_invalid_attributes
      invalid_admin_form.save

      assert_equal 1, invalid_admin_form.errors.messages[:password].size
      assert_equal 0, invalid_admin_form.errors.messages[:password_confirmation].size
      assert_equal 1, invalid_admin_form.errors.messages[:name].size
      assert_equal 2, invalid_admin_form.errors.messages[:email].size
    end

    def test_site_modules_initialization
      assert_equal [], AdminForm.new.site_modules
    end

    def test_confirmation_email_delivery_for_new_record
      assert_difference "ActionMailer::Base.deliveries.size", 1 do
        valid_admin_form.save
      end
    end

    def test_confirmation_email_delivery_for_existing_record
      admin_edit_form = AdminForm.new(id: admin.id)

      assert_no_difference "ActionMailer::Base.deliveries.size" do
        admin_edit_form.save
      end
    end
  end
end
