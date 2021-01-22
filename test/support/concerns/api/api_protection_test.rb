# frozen_string_literal: true

module Api
  module ApiProtectionTest

    def setup_api_protection_test(opts = {})
      @api_protection_test_path = opts[:path]
      @api_protection_test_site = opts[:site]
      @api_protection_test_admin = opts[:admin]
      @api_protection_test_token_with_domain = opts[:token_with_domain]
      @api_protection_test_token_with_other_domain = opts[:token_with_other_domain]
      @api_protection_test_basic_auth_header = "Basic #{Base64.encode64("username:password")}"
      @api_protection_test_admin_auth_header = "Bearer #{@api_protection_test_admin.primary_api_token}"
    end

    def test_index_with_password_protected_site
      @api_protection_test_site.draft!
      @api_protection_test_site.configuration.password_protection_username = "username"
      @api_protection_test_site.configuration.password_protection_password = "password"

      %w(staging production).each do |environment|
        Rails.stub(:env, ActiveSupport::StringInquirer.new(environment)) do
          with(site: @api_protection_test_site) do
            get @api_protection_test_path, as: :json
            assert_response :unauthorized

            get @api_protection_test_path, as: :json, headers: { "Authorization" => @api_protection_test_basic_auth_header }
            assert_response :unauthorized

            @api_protection_test_admin.regular!
            @api_protection_test_admin.admin_sites.create(site: @api_protection_test_site)
            get @api_protection_test_path, as: :json, headers: { "Authorization" => @api_protection_test_admin_auth_header }
            assert_response :success

            @api_protection_test_admin.admin_sites.destroy_all
            get @api_protection_test_path, as: :json, headers: { "Authorization" => @api_protection_test_admin_auth_header }
            assert_response :unauthorized

            @api_protection_test_admin.manager!
            get @api_protection_test_path, as: :json, headers: { "Authorization" => @api_protection_test_admin_auth_header }
            assert_response :success
          end
        end
      end
    end

    def test_index_with_internal_site_request
      @api_protection_test_site.draft!
      @api_protection_test_site.configuration.password_protection_username = "username"
      @api_protection_test_site.configuration.password_protection_password = "password"

      %w(staging production).each do |environment|
        Rails.stub(:env, ActiveSupport::StringInquirer.new(environment)) do
          with(site: @api_protection_test_site) do
            # Nil referrer and no authorization provides unauthorized
            get @api_protection_test_path, as: :json, headers: { "HTTP_REFERER" => "" }
            assert_response :unauthorized

            # Nil referrer authorized should success
            get @api_protection_test_path, as: :json, headers: { "Authorization" => "Bearer #{@api_protection_test_token_with_domain}", "HTTP_REFERER" => "" }
            assert_response :success

            get @api_protection_test_path, as: :json, headers: { "HTTP_REFERER" => "http://#{@api_protection_test_site.domain}/wadus.html" }
            assert_response :success

            get @api_protection_test_path, as: :json, headers: { "Authorization" => @api_protection_test_basic_auth_header, "HTTP_REFERER" => "http://#{@api_protection_test_site.domain}/wadus.html" }
            assert_response :success

            get @api_protection_test_path, as: :json, headers: { "Authorization" => "Bearer #{@api_protection_test_token_with_domain}", "HTTP_REFERER" => "http://#{@api_protection_test_site.domain}/wadus.html" }
            assert_response :success

            get @api_protection_test_path, as: :json, headers: { "Authorization" => "Bearer #{@api_protection_test_token_with_other_domain}", "HTTP_REFERER" => "http://#{@api_protection_test_site.domain}/wadus.html" }
            assert_response :success
          end
        end
      end
    end

    def test_index_with_domain_token
      @api_protection_test_site.draft!
      @api_protection_test_site.configuration.password_protection_username = "username"
      @api_protection_test_site.configuration.password_protection_password = "password"

      %w(staging production).each do |environment|
        Rails.stub(:env, ActiveSupport::StringInquirer.new(environment)) do
          with(site: @api_protection_test_site) do
            get @api_protection_test_path, as: :json
            assert_response :unauthorized

            get @api_protection_test_path, as: :json, headers: { "Authorization" => @api_protection_test_basic_auth_header }
            assert_response :unauthorized

            self.host = @api_protection_test_token_with_domain.domain
            get @api_protection_test_path, as: :json, headers: { "Authorization" => "Bearer #{@api_protection_test_token_with_domain}" }
            assert_response :success

            get @api_protection_test_path, as: :json, headers: { "Authorization" => "Bearer #{@api_protection_test_token_with_other_domain}" }
            assert_response :unauthorized

            self.host = @api_protection_test_token_with_other_domain.domain
            get @api_protection_test_path, as: :json, headers: { "Authorization" => "Bearer #{@api_protection_test_token_with_domain}" }
            assert_response :unauthorized

            get @api_protection_test_path, as: :json, headers: { "Authorization" => "Bearer #{@api_protection_test_token_with_other_domain}" }
            assert_response :success
          end
        end
      end
    end
  end
end
