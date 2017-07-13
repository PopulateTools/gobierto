require "test_helper"

class Subscribers::GobiertoBudgetsBudgetLineActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  LOCALHOST = '127.0.0.1'

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::GobiertoBudgetsBudgetLineActivity.new('activities')
  end

  def ip_address
    @ip_address ||= IPAddr.new(LOCALHOST)
  end

  def create_event(index, area)
    Event.new(name: "gobierto_budgets.budgets_#{index}_#{area.area_name}_updated",
      payload: {
        subject: site,
        ip: LOCALHOST,
        site_id: site.id
      }
    )
  end

  def test_budgets_forecast_economic_updated_handling
    assert_difference 'Activity.count' do
      subject.budgets_forecast_economic_updated(
        create_event('forecast', GobiertoBudgets::EconomicArea)
      )
    end

    activity = Activity.last

    assert_equal site, activity.subject
    assert_equal ip_address, activity.subject_ip
    assert_equal 'gobierto_budgets.budgets_forecast_economic_updated', activity.action
    assert_equal site.id, activity.site_id
    refute activity.admin_activity
  end

  def test_budgets_forecast_functional_updated_handling
    assert_difference 'Activity.count' do
      subject.budgets_forecast_functional_updated(
        create_event('forecast', GobiertoBudgets::FunctionalArea)
      )
    end

    activity = Activity.last

    assert_equal site, activity.subject
    assert_equal 'gobierto_budgets.budgets_forecast_functional_updated', activity.action
  end

  def test_budgets_forecast_custom_updated_handling
    assert_difference 'Activity.count' do
      subject.budgets_forecast_custom_updated(
        create_event('forecast', GobiertoBudgets::CustomArea)
      )
    end

    activity = Activity.last

    assert_equal site, activity.subject
    assert_equal 'gobierto_budgets.budgets_forecast_custom_updated', activity.action
  end

  def test_budgets_execution_economic_updated_handling
    assert_difference 'Activity.count' do
      subject.budgets_execution_economic_updated(
        create_event('execution', GobiertoBudgets::EconomicArea)
      )
    end

    activity = Activity.last

    assert_equal site, activity.subject
    assert_equal 'gobierto_budgets.budgets_execution_economic_updated', activity.action
  end

  def test_budgets_execution_functional_updated_handling
    assert_difference 'Activity.count' do
      subject.budgets_execution_functional_updated(
        create_event('execution', GobiertoBudgets::FunctionalArea)
      )
    end

    activity = Activity.last

    assert_equal site, activity.subject
    assert_equal 'gobierto_budgets.budgets_execution_functional_updated', activity.action
  end

  def test_budgets_execution_custom_updated_handling
    assert_difference 'Activity.count' do
      subject.budgets_execution_custom_updated(
        create_event('execution', GobiertoBudgets::CustomArea)
      )
    end

    activity = Activity.last

    assert_equal site, activity.subject
    assert_equal 'gobierto_budgets.budgets_execution_custom_updated', activity.action
  end

end
