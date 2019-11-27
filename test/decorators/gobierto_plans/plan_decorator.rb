# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class PlanDecoratorTest < ActiveSupport::TestCase
    def plan
      @plan ||= gobierto_plans_plans(:strategic_plan)
    end

    def plan_without_configuration
      @plan_without_configuration ||= gobierto_plans_plans(:economic_plan)
    end

    def site
      @site ||= sites(:madrid)
    end

    def decorated_plan
      @decorated_plan ||= PlanDecorator.new(plan)
    end

    def decorated_plan_without_configuration
      @decorated_plan_without_configuration ||= PlanDecorator.new(plan_without_configuration)
    end

    def test_to_s
      plan_string = decorated_plan.to_s

      assert plan_string.include? "3 axes"
      assert plan_string.include? "1 line of action"
      assert plan_string.include? "2 actions"
      assert plan_string.include? "2 projects/actions"
    end

    def test_plan_without_configuration_to_s
      plan.update_attribute(:configuration_data, nil)

      plan_string = decorated_plan.to_s

      assert plan_string.include? "3 items of level 1"
      assert plan_string.include? "1 item of level 2"
      assert plan_string.include? "2 items of level 3"
      assert plan_string.include? "2 projects"
    end

    def test_plan_without_configuration_with_empty_vocabulary_to_s
      empty_vocabulary = site.vocabularies.create(name: "Empty vocabulary")
      plan.update_attribute(:vocabulary_id, empty_vocabulary.id)

      assert_empty decorated_plan.to_s
    end

    def test_plan_without_configuration_without_vocabulary_to_s
      plan_without_configuration.update_attribute(:vocabulary_id, nil)

      assert_empty decorated_plan_without_configuration.to_s
    end

    def test_plan_without_configuration_with_empty_vocabulary_level_keys
      empty_vocabulary = site.vocabularies.create(name: "Empty vocabulary")
      plan_without_configuration.update_attribute(:vocabulary_id, empty_vocabulary.id)

      level_keys = decorated_plan_without_configuration.level_keys

      assert_equal 2, level_keys.keys.count
    end

    def test_plan_without_configuration_without_vocabulary_level_keys
      plan_without_configuration.update_attribute(:vocabulary_id, nil)

      level_keys = decorated_plan_without_configuration.level_keys

      assert_equal 2, level_keys.keys.count
    end

    def test_level_keys_of_plan
      assert_equal decorated_plan.level_keys, plan.configuration_data.slice("level0", "level1", "level2", "level3")
    end
  end
end
