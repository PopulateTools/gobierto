# frozen_string_literal: true

require "test_helper"

class AhoyTrackingTest < ActionDispatch::IntegrationTest
  def path
    @path ||= root_path
  end

  def visit_ip
    @visit_ip ||= "81.0.32.62"
  end

  def masked_visit_ip
    @masked_visit_ip ||= "81.0.32.0"
  end

  def user_agent_header
    @user_agent_header ||= "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.17 Safari/537.36"
  end

  def root_path_params
    {
      "controller" => "gobierto_budgets/budgets_elaboration",
      "action" => "index",
      "method" => "GET"
    }
  end

  def site
    @site ||= sites(:madrid)
  end

  def user
    @user ||= users(:dennis)
  end

  def test_job_without_user_agent_header
    # In this case the visit is ignored and there is no current_visit available
    # in the controller

    Ahoy::Visit.stub_any_instance(:id, "ahoy!") do
      with_requests_tracking_enabled do
        with_signed_in_user(user) do
          assert_enqueued_with(job: ::GobiertoCommon::EventCreatorJob, args: [site.id, user.id, nil, root_path_params], queue: "event_creators") do
            visit path
          end
        end
      end
    end
  end

  def test_job_enqueued
    page.driver.header("user-agent", user_agent_header)

    Ahoy::Visit.stub_any_instance(:id, "ahoy!") do
      with_requests_tracking_enabled do
        with_signed_in_user(user) do
          assert_enqueued_with(job: ::GobiertoCommon::EventCreatorJob, args: [site.id, user.id, "ahoy!", root_path_params], queue: "event_creators") do
            visit path
          end
        end
      end
    end
  end

  def test_index_not_logged_in
    page.driver.header("user-agent", user_agent_header)

    ActionDispatch::Request.stub_any_instance(:remote_ip, visit_ip) do
      with_requests_tracking_enabled do
        assert 0, Ahoy::Visit.count
        assert 0, Ahoy::Event.count
        assert_performed_jobs 1 do
          visit path
        end

        assert_equal 1, Ahoy::Visit.count
        visit = Ahoy::Visit.last
        assert_equal visit.ip, masked_visit_ip

        assert_equal 1, Ahoy::Event.count
        event = Ahoy::Event.last
        assert_nil event.user_id
        assert_equal event.visit, visit
      end
    end
  end

  def test_index_logged_in
    page.driver.header("user-agent", user_agent_header)

    ActionDispatch::Request.stub_any_instance(:remote_ip, visit_ip) do
      with_requests_tracking_enabled do
        with_signed_in_user(user) do
          assert 0, Ahoy::Visit.count
          assert 0, Ahoy::Event.count
          assert_performed_jobs 1 do
            visit path
          end

          assert_equal 1, Ahoy::Visit.count
          visit = Ahoy::Visit.last
          assert_equal visit.ip, masked_visit_ip

          assert_equal 1, Ahoy::Event.count
          event = Ahoy::Event.last
          assert_equal user, event.user
          assert_equal event.visit, visit
        end
      end
    end
  end
end
