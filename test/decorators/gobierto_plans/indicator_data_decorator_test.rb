# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class PlanDataDecoratorTest < ActiveSupport::TestCase

    def setup
    end

    def test_export_plan_to_csv_without_indicators
      plan = gobierto_plans_plans(:strategic_plan) # plan_categories_vocabulary [people_and_families_plan_term welfare_payments_plan_term center_scholarships_plan_term center_basic_needs_plan_term economy_plan_term city_plan_term]
      assert_equal "Node.Title,Node.external_id,custom_field\n", IndicatorDataDecorator.new(plan).csv
    end

    def test_export_plan_to_csv_with_single_indicator
      plan = gobierto_plans_plans(:dashboards_plan) # dashboards_plan_categories_vocabulary and with 2 projects aka nodes
      custom_field = ::GobiertoCommon::CustomField.where(instance: plan)

      dashboard_project = gobierto_plans_nodes(:dashboard_project) # economy_plan_term
      records_dashboard = ::GobiertoCommon::CustomFieldRecord.where(item: dashboard_project)
      # without indicators
      dashboard_alternative_project = gobierto_plans_nodes(:political_agendas) # center_basic_needs_plan_term
      records_dashboard_alternative = ::GobiertoCommon::CustomFieldRecord.where(item: dashboard_alternative_project)

      expected = [
          "Node.Title,Node.external_id,custom_field,col_1,col_2,col_3,col_4",
          "Dashboards plan,,project-metrics,2018-07-30,28,Decretos Emitidos,55",
          "Dashboards plan,,project-metrics,2017-08-10,13,decretos emitidos,95",
          "Dashboards plan,,project-metrics,2016-08-04,37,decretos   emitidos,74",
          "Dashboards plan,,project-metrics,2015-05-08,32,Notificaciones enviadas,98",
          "Dashboards plan,,project-metrics,2019-12-07,48,Expedientes cerrados,57",
          "Dashboards plan,,project-metrics,2020-01-01,10,Expedientes cerrados,20",
          "Dashboards plan,,project-metrics,2019-08-10,15,Camas UCI,20",
          "Dashboards plan,,project-metrics,2018-08-04,50,Expedientes cerrados,40",
          "Dashboards plan,,project-metrics,2021-12-31,356,camas uci,270",
          ""
        ]
      assert_equal expected.join("\n"), IndicatorDataDecorator.new(plan).csv
    end

    def test_export_plan_to_csv_with_multiples_indicator_and_different_length_of_columns
      plan = gobierto_plans_plans(:dashboards_plan)
    end

    def test_csv_with_different_columns_length
    end

  end

end
