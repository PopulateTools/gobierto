# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class PlanDataDecoratorTest < ActiveSupport::TestCase

    def test_export_plan_to_csv_without_indicators
      plan = gobierto_plans_plans(:strategic_plan) # plan_categories_vocabulary [people_and_families_plan_term welfare_payments_plan_term center_scholarships_plan_term center_basic_needs_plan_term economy_plan_term city_plan_term]
      assert_equal "Node.Title,Node.external_id,custom_field\n", IndicatorDataDecorator.new(plan).csv
    end

    def test_export_plan_to_csv_with_single_indicator
      plan = gobierto_plans_plans(:dashboards_plan)
      expected = [
          "Node.Title,Node.external_id,custom_field,col_1,col_2,col_3,col_4",
          "Dashboards plan,4,project-metrics,2018-07-30,28,Decretos Emitidos,55",
          "Dashboards plan,4,project-metrics,2017-08-10,13,decretos emitidos,95",
          "Dashboards plan,4,project-metrics,2016-08-04,37,decretos   emitidos,74",
          "Dashboards plan,4,project-metrics,2015-05-08,32,Notificaciones enviadas,98",
          "Dashboards plan,4,project-metrics,2019-12-07,48,Expedientes cerrados,57",
          "Dashboards plan,5,project-metrics,2020-01-01,10,Expedientes cerrados,20",
          "Dashboards plan,5,project-metrics,2019-08-10,15,Camas UCI,20",
          "Dashboards plan,5,project-metrics,2018-08-04,50,Expedientes cerrados,40",
          "Dashboards plan,5,project-metrics,2021-12-31,356,camas uci,270",
          ""
        ]
      assert_equal expected.join("\n"), IndicatorDataDecorator.new(plan).csv
    end

    def test_export_plan_to_csv_with_multiples_indicator_and_different_length_of_columns
      plan = gobierto_plans_plans(:multiple_indicators_plan)
      expected = [
        "Node.Title,Node.external_id,custom_field,col_1,col_2,col_3,col_4,col_5,col_6,col_7",
        "Indicator example plan,6,multiple-indicators-statistical,2019-01-01,3,20,5,10,1,95",
        "Indicator example plan,6,multiple-indicators-statistical,2020-01-01,2,20,2,5,3,90",
        "Indicator example plan,6,multiple-indicators-statistical,2021-01-01,0,20,1,3,4,99",
        "Indicator example plan,7,multiple-indicators-opinion,2019-01-01,40,60,,,,",
        "Indicator example plan,7,multiple-indicators-opinion,2020-01-01,50,50,,,,",
        "Indicator example plan,7,multiple-indicators-opinion,2021-01-01,70,30,,,,",
        ""
      ]
      assert_equal expected.join("\n"), IndicatorDataDecorator.new(plan).csv
    end

  end
end
